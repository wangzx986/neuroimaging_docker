## Use Ubuntu 20.04 (Focal Fossa) as the base image
#FROM ubuntu:20.04
#
## Set environment variables
#ENV DEBIAN_FRONTEND=noninteractive
#
## Set ARGs for UID, GID, and username, allowing to run docker container with the same user ID and group ID as your active directory user
## It ensures that files created inside the container have the same ownership as the user who runs the container
#ARG USER_ID
#ARG GROUP_ID
#ARG U=USERNAME
#
#
#
## Update and install system dependencies globally 
#RUN apt-get update && apt-get install -y \
#    software-properties-common \
#    wget \
#    curl \
#    git \
#    acl \
#    build-essential \
#    libssl-dev \
#    zlib1g-dev \
#    libbz2-dev \
#    libreadline-dev \
#    libsqlite3-dev \
#    llvm \
#    libncurses5-dev \
#    libncursesw5-dev \
#    xz-utils \
#    tk-dev \
#    libffi-dev \
#    liblzma-dev \
#    python3-openssl \
#    libglib2.0-0 \
#    libxrender-dev \
#    libxt6 \
#    tcsh \
#    gcc-10 g++-10 \
#    && apt-get clean
#
#
## Create a directory for Conda and Python installations
#RUN mkdir -p /opt/conda
#
#############################################     MINICONDA && PYTHON ENVIRONMENT    #######################################
## Install Miniconda to /opt/conda
#RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
#    bash /tmp/miniconda.sh -b -p /opt/conda/miniconda && \
#    rm /tmp/miniconda.sh
## Set up Conda environment
#ENV PATH=/opt/conda/miniconda/bin:$PATH
#
## Initialize Conda for bash, because by default, docker uses /bin/sh, but conda commands need /bin/bash
#SHELL ["/bin/bash", "-c"]
#
## Initialize conda environment in noniteractive mode and Activate Conda environment and install packages
#RUN source /opt/conda/miniconda/etc/profile.d/conda.sh && \
#    conda create -n myenv python=3.11 && \
#    conda run -n myenv conda install -y -c conda-forge numpy plotly nibabel pybids scipy pandas matplotlib scikit-learn dipy nilearn seaborn && \
#    conda run -n myenv pip install pyAFQ && \
#    conda clean --all -f -y
## Fix utils.py for pyAFQ 
#COPY utils.py /opt/conda/miniconda/envs/myenv/lib/python3.11/site-packages/AFQ/definitions/
## Revert back to the default shell for other installations like FSL
#SHELL ["/bin/sh", "-c"]
## Set PATH for myenv
#ENV PATH=/opt/conda/miniconda/envs/myenv/bin:$PATH
#
#
#
###############################################       FSL     ##################################################################
## Install FSL (FMRIB Software Library) using Miniconda's Python
#RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py -O /tmp/fslinstaller.py && \
#    /opt/conda/miniconda/bin/python /tmp/fslinstaller.py -d /opt/fsl && \
#    rm /tmp/fslinstaller.py
## Set environment variables for FSL
#ENV FSLDIR=/opt/fsl
#ENV PATH=${FSLDIR}/bin:${PATH}
#ENV FSLOUTPUTTYPE=NIFTI_GZ
#
############################################################   ANTS   ########################################################
## Install the latest version of CMake
#RUN wget https://github.com/Kitware/CMake/releases/download/v3.22.0/cmake-3.22.0-linux-x86_64.sh && \
#    chmod +x cmake-3.22.0-linux-x86_64.sh && \
#    mkdir -p /opt/cmake && \
#    ./cmake-3.22.0-linux-x86_64.sh --skip-license --prefix=/opt/cmake && \
#    rm cmake-3.22.0-linux-x86_64.sh
## Add CMake to the PATH
#ENV PATH=/opt/cmake/bin:$PATH
#
## Clone and build ANTs
#RUN git clone https://github.com/ANTsX/ANTs.git /opt/ants && \
#    mkdir /opt/ants-build && \
#    cd /opt/ants-build && \
#    cmake /opt/ants && \
#    make -j4 && \
#    # Remove the build directory to save space
#    rm -rf /opt/ants-build
## Add ANTs to PATH
#ENV PATH=/opt/ants/bin:$PATH
#
#
############################################################  MRTRIX  #########################################################
#
## Clone and build MRtrix3 without GUI (no OpenGL)
#RUN git clone https://github.com/MRtrix3/mrtrix3.git /opt/mrtrix3 && \
#    cd /opt/mrtrix3 && ./configure -nogui && ./build
## Add MRtrix to PATH
#ENV PATH=/opt/mrtrix3/bin:$PATH
#
#
###########################################################  AFNI    ###########################################################
#
## Install AFNI to a global directory
#RUN curl -O https://afni.nimh.nih.gov/pub/dist/bin/linux_ubuntu_16_64/@update.afni.binaries && \
#    tcsh @update.afni.binaries -defaults -bindir /opt/abin && \
#    rm @update.afni.binaries
## Add AFNI to the PATH (system-wide)
#ENV PATH=/opt/abin:$PATH
#
#
#######################################################  HD-BET   ##############################################################
## Clone and install HD-BET globally
#RUN git clone --depth 1 https://github.com/MIC-DKFZ/HD-BET /opt/HD-BET && \
#    pip3 install -e /opt/HD-BET    
#COPY run.py /opt/HD-BET/run.py
## Add HD-BET to the PATH
#ENV PATH=/opt/HD-BET:$PATH
#
#
#####################################################   FREESURFER   ###########################################################
#
## Use the pre-downloaded FreeSurfer archive
#COPY freesurfer-linux-centos7_x86_64-7.3.2.tar.gz /opt/
## Extract and install FreeSurfer
#RUN tar -xzf /opt/freesurfer-linux-centos7_x86_64-7.3.2.tar.gz -C /opt/ && \
#    rm -rf /opt/freesurfer-linux-centos7_x86_64-7.3.2.tar.gz 
## Copy the FreeSurfer license file into the container
#COPY license-1.txt /opt/freesurfer/license-1.txt
## Set the FS_LICENSE environment variable to point to the correct license file
#ENV FS_LICENSE=/opt/freesurfer/license-1.txt
#ENV FREESURFER_HOME=/opt/freesurfer
#ENV FSFAST_HOME=$FREESURFER_HOME/fsfast
#ENV PATH=$FREESURFER_HOME/bin:$PATH
#
#
## Source the FSL configuration file/freesurfer setup and set environment variables
##COPY entrypoint.sh /opt/entrypoint.sh
##RUN chmod +x /opt/entrypoint.sh
##ENTRYPOINT ["/opt/entrypoint.sh"]
#
################################################################# BELOW IS FIXING LIBRARY ISSUES FOR DOCKER IMAGE  ########################################################################
#
## Copy the pre-downloaded multiarch-support .deb package into the container
#COPY multiarch-support_2.28-10+deb10u4_amd64.deb /tmp/multiarch-support_2.28-10+deb10u4_amd64.deb
## Extract and install multiarch-support manually within /opt folder
#RUN mkdir -p /opt/multiarch-support && \
#    dpkg-deb -x /tmp/multiarch-support_2.28-10+deb10u4_amd64.deb /opt/multiarch-support && \
#    rm /tmp/multiarch-support_2.28-10+deb10u4_amd64.deb
#
## Copy the pre-downloaded .deb package for libxp6 into the container
#COPY libxp6_1.0.2-2_amd64.deb /tmp/libxp6_1.0.2-2_amd64.deb
## Create the /opt/libxp6 directory and extract the package into it
#RUN mkdir -p /opt/libxp6 && \
#    dpkg-deb -x /tmp/libxp6_1.0.2-2_amd64.deb /opt/libxp6 && \
#    rm /tmp/libxp6_1.0.2-2_amd64.deb
#
## Copy the pre-downloaded libpng12 package into the container
#COPY libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~disco_amd64.deb /tmp/libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~disco_amd64.deb
#RUN mkdir -p /opt/libpng12 && \
#    dpkg-deb -x /tmp/libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~disco_amd64.deb /opt/libpng12 && \
#    rm /tmp/libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~disco_amd64.deb
#
#
#
## at bottom of Dockerfile - add anything you need to chown to the list
#RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \ 
#        groupadd -g ${GROUP_ID} ${U} && \
#        useradd -l -u ${USER_ID} -g ${U} ${U} && \
#        install -d -m 0755 -o USERNAME -g ${U} /home/${U} && \
#        chown --changes --silent --no-dereference --recursive \
#                ${USER_ID}:${GROUP_ID} \
#                /home/${U} \
#                /opt/conda \
#                /opt/fsl \
#                /opt/cmake \
#                /opt/ants \
#                /opt/mrtrix3 \
#                /opt/abin \
#                /opt/HD-BET \
#                /opt/freesurfer \
#                /opt/multiarch-support \
#                /opt/libxp6 \
#                /opt/libpng12 \
#        ; fi
#
#
#
## Switch to the newly created user
#USER ${U}
#
## Define an entry point (optional)
#CMD ["bash"]



################################################   RELEASE NON-ROOT-USER ONWERSHIP TO /var ####################################################
#FROM wangzx94/neuroimaging_py311_update:latest 
#
#ARG USER_ID
#ARG GROUP_ID
#ARG U=USERNAME
#
#USER root
#
#RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
#        chown --changes --silent --no-dereference --recursive \
#                ${USER_ID}:${GROUP_ID} \
#                /var \
#        ; fi
#
#USER ${U}
#
#CMD ["bash"]

#############################################  EXPORT PATH FOR LIBRARIES  ######################################################################
FROM wangzx94/neuroimaging_py311_update:latest 

ARG USER_ID
ARG GROUP_ID
ARG U=USERNAME

ENV LD_LIBRARY_PATH=/opt/libxp6/usr/lib/x86_64-linux-gnu:/opt/libpng12/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

USER ${U}
WORKDIR /home/${U}

CMD ["bash"]
