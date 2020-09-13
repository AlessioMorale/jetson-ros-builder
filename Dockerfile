ARG sourceimage
FROM $sourceimage
RUN mkdir /buildtools
ENV release_name=bionic
ENV ROS_DISTRO=melodic

# add ros melodic repo
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu ${release_name} main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# install the base environment and all build tools
RUN apt-get update && \
    apt-get install python-pip ros-${ROS_DISTRO}-robot -y --no-install-recommends && \
    apt-get clean autoclean -y

RUN pip3 --no-cache-dir install -U setuptools
RUN pip --no-cache-dir install -U rosdep rosinstall_generator vcstool rosinstall empy catkin-tools
RUN pip3 --no-cache-dir install -U rosdep rosinstall_generator vcstool rosinstall empy catkin-tools

# complete the ros installation
RUN rosdep init && \
    rosdep update

COPY /resources/docker-entrypoint.sh /
COPY /resources/init_workspaces /


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
