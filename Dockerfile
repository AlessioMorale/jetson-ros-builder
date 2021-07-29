FROM alessiomorale/jetson-builder-cv:r32.5.0_cv4.4.0_1.3.4
RUN mkdir /buildtools
ENV release_name=bionic
ENV ROS_DISTRO=melodic

# add ros melodic repo
RUN echo "deb http://packages.ros.org/ros/ubuntu ${release_name} main" > /etc/apt/sources.list.d/ros-latest.list && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# install the base environment and all build tools
RUN apt-get update && \
    apt-get install python-pip ros-${ROS_DISTRO}-robot python-catkin-tools -y --no-install-recommends && \
    apt-get clean autoclean -y && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 --no-cache-dir install -U setuptools
RUN pip3 --no-cache-dir install -U rosdep rosinstall_generator vcstool rosinstall empy

# add exclusions for opencv*
COPY /resources/opencv_overrides.yaml /etc/ros/rosdep/
RUN mkdir -p /etc/ros/rosdep/sources.list.d/ && \
    echo "yaml file:///etc/ros/rosdep/opencv_overrides.yaml" >> /etc/ros/rosdep/sources.list.d/05-default.list

# complete the ros installation
RUN rosdep init && \
    rosdep update

COPY /resources/docker-entrypoint.sh /
COPY /resources/init_workspaces /


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
