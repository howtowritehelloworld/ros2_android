# Multi-architecture Dockerfile to build Rosdroid ARM64 Ubuntu 26.04 + ROS 2 Lyrical Rootfs
FROM --platform=linux/arm64 ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO=lyrical
ENV CMAKE_POLICY_VERSION_MINIMUM=3.5

# 1. Base packages & locales
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    curl \
    gnupg2 \
    lsb-release \
    ca-certificates \
    build-essential \
    cmake \
    git \
    python3-pip \
    net-tools \
    iproute2 \
    sudo \
    nano \
    dropbear \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# 2. Add ROS 2 Lyrical repository (Ubuntu 26.04 Resolute)
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=arm64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu resolute main" > /etc/apt/sources.list.d/ros2.list

# 3. Install ROS 2 Lyrical base. ros-base already depends on Fast DDS 3 (rmw_fastrtps_cpp).
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-lyrical-ros-base \
    ros-lyrical-rmw-fastrtps-cpp \
    ros-dev-tools \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

# 4. Initialize rosdep
RUN rosdep init || true \
    && rosdep update

# 5. Build Micro-ROS Agent
RUN mkdir -p /root/uros_ws/src \
    && cd /root/uros_ws/src \
    && git clone -b lyrical https://github.com/micro-ROS/micro_ros_setup.git \
    && cd /root/uros_ws \
    && . /opt/ros/lyrical/setup.sh \
    && colcon build \
    && . install/setup.sh \
    && sed -i 's/--os=ubuntu:noble/--os=ubuntu:resolute/' \
         $(grep -rl -- '--os=ubuntu:noble' /root/uros_ws/install/micro_ros_setup) \
    && ros2 run micro_ros_setup create_agent_ws.sh \
    && ros2 run micro_ros_setup build_agent.sh \
    && rm -rf /root/uros_ws/build /root/uros_ws/log

# 6. Copy and compile patch_getifaddrs
COPY configs/patch_getifaddrs.c /tmp/patch_getifaddrs.c
RUN gcc -shared -fPIC -o /usr/local/lib/patch_getifaddrs.so /tmp/patch_getifaddrs.c -ldl \
    && echo "/usr/local/lib/patch_getifaddrs.so" > /etc/ld.so.preload \
    && rm /tmp/patch_getifaddrs.c

# 7. Create default rosdroid user. Ubuntu 26.04 images already use UID 1000 for "ubuntu".
RUN if id ubuntu >/dev/null 2>&1; then userdel -r ubuntu || userdel ubuntu; fi \
    && useradd -m -s /bin/bash -u 1000 rosdroid \
    && echo "rosdroid:rosdroid" | chpasswd \
    && echo "root:rosdroid" | chpasswd \
    && echo "rosdroid ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && useradd -m -s /bin/bash -u 1001 -g rosdroid robot \
    && echo "robot:rosdroid" | chpasswd \
    && echo "robot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && ln -s /home/rosdroid /home/robot_alias

# 8. Fast DDS 3 phone profile. UDP only: shared memory does not work under PRoot.
COPY configs/fastdds.xml /etc/fastdds/phone.xml
RUN echo "source /opt/ros/lyrical/setup.bash" >> /root/.bashrc \
    && echo "source /root/uros_ws/install/setup.bash" >> /root/.bashrc \
    && echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> /root/.bashrc \
    && echo "export ROS_DOMAIN_ID=156" >> /root/.bashrc \
    && echo "export ROS_LOCALHOST_ONLY=0" >> /root/.bashrc \
    && echo "export FASTDDS_DEFAULT_PROFILES_FILE=/etc/fastdds/phone.xml" >> /root/.bashrc \
    && echo "export LD_PRELOAD=/usr/local/lib/patch_getifaddrs.so" >> /root/.bashrc

CMD ["/bin/bash"]
