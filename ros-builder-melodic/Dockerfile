FROM mdegans/tegra-opencv:jp-r32.4.2-cv-4.3.0
RUN mkdir /buildtools
COPY install_build_env /buildtools/
COPY build_workspace /buildtools/
COPY generate_rosinstall /buildtools/

RUN /buildtools/install_build_env