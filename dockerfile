FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

# ========== Anaconda ==========
# https://github.com/ContinuumIO/docker-images/blob/master/anaconda/Dockerfile

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion dbus

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda2-4.4.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

# Install basic dependencies
RUN apt-get install -y cmake build-essential pkg-config libpython3-dev \
    libboost-python-dev libboost-dev libassimp-dev libgl1-mesa-dev \
    libglu1-mesa-dev libglu1-mesa libtinyxml-dev python3 zlib1g-dev
RUN apt-get install -y libgtk2.0-dev

RUN conda create -y -n deeprlbootcamp python=3.5.3

ENV PYTHONPATH /root/code/bootcamp_pg:$PYTHONPATH

ENV PATH /opt/conda/envs/deeprlbootcamp/bin:$PATH

RUN echo "source activate deeprlbootcamp" >> /root/.bashrc

ADD _build/environment.yml /tmp/environment.yml

RUN conda env update -f /tmp/environment.yml


RUN apt-get install -y xvfb
RUN apt-get install -y x11vnc
RUN apt-get install -y freeglut3-dev
RUN apt-get install -y mesa-common-dev

# ========== Roboschool ==========

ENV ROBOSCHOOL_PATH /opt/roboschool

RUN /opt/conda/envs/deeprlbootcamp/bin/pip install PyQt5==5.9

ENV PKG_CONFIG_PATH /opt/conda/envs/deeprlbootcamp/lib/pkgconfig


RUN git clone https://github.com/openai/roboschool.git $ROBOSCHOOL_PATH
RUN cd $ROBOSCHOOL_PATH && git checkout c1e72a280f5b9fda2b9215b93e23b3c4861bce4b

RUN git clone https://github.com/olegklimov/bullet3 -b roboschool_self_collision /opt/bullet3 && \
    cd /opt/bullet3 && \
    git checkout 3687507ddc04a15de2c5db1e349ada3f2b34b3d6 && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 -DCMAKE_INSTALL_PREFIX:PATH=$ROBOSCHOOL_PATH/roboschool/cpp-household/bullet_local_install -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF -DBUILD_OPENGL3_DEMOS=OFF .. && \
    make -j4 && \
    make install

RUN apt-get install libglu1-mesa-dev -y
RUN apt-get install qtbase5-dev -y

RUN /opt/conda/envs/deeprlbootcamp/bin/pip install -e $ROBOSCHOOL_PATH

RUN apt-get install -y mesa-utils

RUN /opt/conda/envs/deeprlbootcamp/bin/pip install awscli

WORKDIR /root/code/bootcamp_pg

# Hot fix
RUN cd $ROBOSCHOOL_PATH && git pull origin master && git checkout a7e7fd5cc8f81e9691f9bbe8c9aab8e87c79bb7d

RUN apt-get install -y iproute iputils-ping

#RUN conda install -y -n deeprlbootcamp notebook