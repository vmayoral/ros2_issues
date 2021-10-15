# build: docker build -t ros2speedtest .
# run: docker run -it ros2speedtest

ARG DISTRO=galactic
FROM ros:$DISTRO

# all variables are reset at FROM, so set the distro again
ARG DISTRO=galactic
# ARG MIDDLEWARE_USED=cyclonedds  # cyclonedds or fastrtps
ARG DEBIAN_FRONTEND=noninteractive

#######################
# Fix mess with ROS GPG Key Expiration
#######################
# https://discourse.ros.org/t/ros-gpg-key-expiration-incident/20669/27
RUN apt-get update || true \
    && apt install -y curl \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && apt-get update


# install helpful developer tools
RUN apt-get update && apt-get install -y \
      bash-completion \
      byobu \
      htop \
      python3-argcomplete \
    && rm -rf /var/lib/apt/lists/*

# install Fast-DDS
RUN apt-get update && apt-get install -y ros-$DISTRO-rmw-fastrtps-cpp

RUN mkdir -p /opt/issue_ws/src
WORKDIR /opt/issue_ws
COPY . src/ros2_issues
RUN /bin/bash -c ". /opt/ros/$DISTRO/setup.bash \
      && colcon build --symlink-install"

WORKDIR /opt
COPY fastrtps.conf cyclonedds.conf /opt/

# ENV ROS_LOCALHOST_ONLY=0
ENV ROS_LOCALHOST_ONLY=1

ENTRYPOINT ["/usr/bin/byobu", "-f", "cyclonedds.conf", "attach"]
