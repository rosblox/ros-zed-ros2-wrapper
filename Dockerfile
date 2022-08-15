FROM --platform=arm64 dustynv/ros:foxy-ros-base-l4t-r34.1.1

ARG ZED_SDK_URL="https://download.stereolabs.com/zedsdk/3.7/l4t34.1/jetsons"
ARG ZED_SDK_RUN="ZED_SDK_Linux_JP.run"

RUN cd /tmp && \
    wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${ZED_SDK_URL} -O ${ZED_SDK_RUN} && \
    chmod +x ${ZED_SDK_RUN} && \
    ./${ZED_SDK_RUN} silent skip_tools && \
    rm -rf /usr/local/zed/resources/* && \
    rm -rf ${ZED_SDK_RUN} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

WORKDIR /colcon_ws

ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

RUN git clone --recursive https://github.com/stereolabs/zed-ros2-wrapper src/zed-ros2-wrapper && \
    apt-get update && \
    rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y --skip-keys "rtabmap find_object_2d Pangolin libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv" && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    . /opt/ros/${ROS_DISTRO}/setup.sh && \
    colcon build --symlink-install --event-handlers console_direct+ --base-paths src/zed-ros2-wrapper --cmake-args ' -DCMAKE_BUILD_TYPE=Release' ' -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs' ' -DCMAKE_CXX_FLAGS="-Wl,--allow-shlib-undefined"'

WORKDIR /

COPY ros_entrypoint.sh .
