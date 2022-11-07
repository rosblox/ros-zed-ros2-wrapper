FROM --platform=arm64  alpine:latest as unzipper

RUN apk add unzip wget curl
WORKDIR /opt
RUN wget https://github.com/ros/xacro/archive/refs/tags/2.0.8.tar.gz -O - | tar -xvz && mv xacro-2.0.8 xacro
RUN wget https://github.com/ros/diagnostics/archive/refs/tags/3.0.0.tar.gz -O - | tar -xvz && mv diagnostics-3.0.0 diagnostics


FROM --platform=arm64 dustynv/ros:humble-ros-base-l4t-r35.1.0

ARG ZED_SDK_URL="https://download.stereolabs.com/zedsdk/3.8/l4t35.1/jetsons"
ARG ZED_SDK_RUN="ZED_SDK_Linux_JP.run"

RUN cd /tmp && \
    apt update && apt install zstd -y --no-install-recommends && \
    wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${ZED_SDK_URL} -O ${ZED_SDK_RUN} && \
    chmod +x ${ZED_SDK_RUN} && \
    ./${ZED_SDK_RUN} silent skip_tools && \
    rm -rf /usr/local/zed/resources/* && \
    rm -rf ${ZED_SDK_RUN} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

WORKDIR /colcon_ws

COPY  --from=unzipper /opt/xacro src/xacro    
COPY  --from=unzipper /opt/diagnostics src/diagnostics    

RUN git clone --recursive https://github.com/stereolabs/zed-ros2-wrapper src/zed-ros2-wrapper && \
    . /opt/ros/${ROS_DISTRO}/install/setup.sh && \
    colcon build --symlink-install --event-handlers console_direct+ --base-paths src --cmake-args ' -DCMAKE_BUILD_TYPE=Release' ' -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs' ' -DCMAKE_CXX_FLAGS="-Wl,--allow-shlib-undefined"'

WORKDIR /

COPY ros_entrypoint.sh .
