FROM --platform=arm64  alpine:latest as unzipper

RUN apk add unzip wget curl
WORKDIR /opt

ARG XACRO_VERSION=2.0.8
RUN wget https://github.com/ros/xacro/archive/refs/tags/${XACRO_VERSION}.tar.gz -O - | tar -xvz && mv xacro-${XACRO_VERSION} xacro
ARG DIAGNOSTICS_VERSION=3.0.0
RUN wget https://github.com/ros/diagnostics/archive/refs/tags/${DIAGNOSTICS_VERSION}.tar.gz -O - | tar -xvz && mv diagnostics-${DIAGNOSTICS_VERSION} diagnostics



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

COPY ./zed-ros2-wrapper src/zed-ros2-wrapper

RUN . /opt/ros/${ROS_DISTRO}/install/setup.sh && \
    colcon build --symlink-install --event-handlers console_direct+ --base-paths src --cmake-args ' -DCMAKE_BUILD_TYPE=Release' ' -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs' ' -DCMAKE_CXX_FLAGS="-Wl,--allow-shlib-undefined"'

WORKDIR /

COPY ros_entrypoint.sh .

RUN echo 'alias build="colcon build --symlink-install  --event-handlers console_direct+"' >> ~/.bashrc
RUN echo 'alias run="ros2 launch zed_wrapper zedm.launch.py"' >> ~/.bashrc
