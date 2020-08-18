ARG sourceimage
FROM $sourceimage
RUN mkdir /buildtools
ENV release_name=bionic
ENV ROS_DISTRO=melodic
# install tzdata avoiding interactive prompts
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install gnupg2 tzdata -y && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean autoclean -y

# add ros melodic repo
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu ${release_name} main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# install the base environment and all build tools
RUN apt-get update && \
    apt-get install build-essential git python3-pip python-pip cmake ros-${ROS_DISTRO}-robot -y --no-install-recommends && \
    pip3 --no-cache-dir install scikit-build && pip3 --no-cache-dir install "opencv-python>=4.3,<4.4"  --install-option="-j3" && \
    pip3 --no-cache-dir install -U rosdep rosinstall_generator vcstool rosinstall empy catkin-tools && \
    apt-get clean autoclean -y
RUN sudo apt install cuda-cudart-10-2 cuda-cufft-10-2 cuda-curand-10-2 cuda-cusolver-10-2 cuda-cusparse-10-2 cuda-npp-10-2 cuda-nvgraph-10-2 \ 
    cuda-nvrtc-10-2 libcublas10 libcudnn8 cuda-compiler-10-2 cuda-minimal-build-10-2 cuda-libraries-dev-10-2 libcudnn8-dev -y --no-install-recommends && \
    apt-get clean autoclean -y

# complete the ros installation
RUN rosdep init && \
    rosdep update

COPY /resources/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
