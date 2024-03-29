FROM dustynv/ros:noetic-ros-base-l4t-r32.7.1
ARG RELEASE=r32.7
ENV release_name=bionic
ENV ROS_DISTRO=noetic
ENV RELEASE=${RELEASE}
# install tzdata avoiding interactive prompts
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && \
    apt-get update -m || true && \
    apt-get install --upgrade ca-certificates curl gnupg2 -y && \
    curl https://repo.download.nvidia.com/jetson/jetson-ota-public.asc -o /etc/jetson-ota-public.key && \
    apt-key add /etc/jetson-ota-public.key && \
    echo "deb https://repo.download.nvidia.com/jetson/common ${RELEASE} main" >> /etc/apt/sources.list.d/nvidia_jetson.list && \
    cat /etc/apt/sources.list.d/nvidia_jetson.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install gnupg2 tzdata -y && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean autoclean -y && \
    rm -rf /var/lib/apt/lists/*

# install the base environment and all build tools
RUN apt-get update && \
    apt-get install build-essential ninja-build cmake git python3 python3-dev python3-pip -y --no-install-recommends && \
    apt-get clean autoclean -y

ARG CUDA_VERSION=10-2
# install cuda & build tools
RUN apt-get install cuda-libraries-${CUDA_VERSION} cuda-libraries-dev-${CUDA_VERSION} cuda-nvtx-${CUDA_VERSION} cuda-minimal-build-${CUDA_VERSION} \
    cuda-command-line-tools-${CUDA_VERSION} cuda-cudart-${CUDA_VERSION} cuda-cufft-${CUDA_VERSION} cuda-curand-${CUDA_VERSION} \
    cuda-cusolver-${CUDA_VERSION} cuda-cusparse-${CUDA_VERSION} cuda-npp-${CUDA_VERSION} cuda-nvgraph-${CUDA_VERSION} \ 
    cuda-nvrtc-${CUDA_VERSION} libcublas10 libcudnn8 libcudnn8-dev -y --no-install-recommends && \
    apt-get clean autoclean -y

SHELL ["/bin/bash", "-c"]
COPY ./resources/setup_ccache /root/

RUN apt-get update && \
    apt-get install -y ccache --no-install-recommends && \
    apt-get install -y libzstd-dev --no-install-recommends && \
    apt-get clean autoclean -y

# Upgrade CCACHE to a version supporting NVCC
RUN mkdir -p /tmp/ccache_build && \
    cd /tmp/ccache_build && \
    git clone --branch v4.6.3 https://github.com/ccache/ccache.git ccache && \
    mkdir -p ccache/build && \
    cd ccache/build && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_SYSCONFDIR=/etc \
    -DREDIS_STORAGE_BACKEND=OFF \
    -DENABLE_TESTING=OFF \
    -DENABLE_DOCUMENTATION=OFF \
    .. && \
    make -j8 && \
    make install && \
    rm -rf /tmp/ccache_build && \
    ccache --version


# add exclusions for opencv*
COPY /resources/opencv_overrides.yaml /etc/ros/rosdep/
RUN mkdir -p /etc/ros/rosdep/sources.list.d/ && \
    echo "yaml file:///etc/ros/rosdep/opencv_overrides.yaml" >> /etc/ros/rosdep/sources.list.d/05-default.list

COPY /resources/docker-entrypoint.sh /
COPY /resources/init_workspaces /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
