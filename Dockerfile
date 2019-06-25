# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.5.4  (apt)
# tensorflow    1.8.0  (pip)
# ==================================================================

FROM nvidia/cudagl:10.0-devel-ubuntu16.04
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ARG APT_INSTALL="apt-get install -y --no-install-recommends"
ARG PIP_INSTALL="python -m pip --no-cache-dir install --upgrade"
ARG GIT_CLONE="git clone --depth 10"

ADD . /code
WORKDIR /code

RUN rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        apt-utils \
        ca-certificates \
        wget \
        git \
        vim \
        curl \
        unzip \
        unrar \
        swig \
        xvfb \
        freeglut3-dev \
        libfontconfig1-dev \
        bzip2 \
        vnc4server && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda env create && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

RUN [ "/bin/bash", "-c", "source activate ml && pip install -e gym" ]

WORKDIR /tmp

RUN wget --quiet https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb && \
    wget --quiet https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7-dev_7.6.0.64-1+cuda10.0_amd64.deb && \
    ldconfig && \
    dpkg -i /tmp/libcudnn7_7.6.0.64-1+cuda10.0_amd64.deb && \
    dpkg -i /tmp/libcudnn7-dev_7.6.0.64-1+cuda10.0_amd64.deb

RUN rm -rf /tmp/*

WORKDIR /code

ENTRYPOINT ["/bin/bash"]
CMD ["run.sh"]
