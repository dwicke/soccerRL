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

#ADD _build/environment.yml /tmp/environment.yml

#RUN conda env update -f /tmp/environment.yml


RUN apt-get install -y xvfb
RUN apt-get install -y x11vnc
RUN apt-get install -y freeglut3-dev
RUN apt-get install -y mesa-common-dev

# ========== Roboschool ==========


RUN apt-get install libglu1-mesa-dev -y
RUN apt-get install qt4-dev-tools -y

RUN apt-get install -y mesa-utils

RUN /opt/conda/envs/deeprlbootcamp/bin/pip install awscli



RUN apt-get install -y libboost-filesystem-dev libboost-system-dev flex

WORKDIR /root/code/
RUN git clone https://github.com/LARG/HFO.git && \
    cd HFO && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=RelwithDebInfo ..
    
WORKDIR /root/code/HFO/build
RUN make -j4
RUN make install

WORKDIR /root/code/HFO
RUN pip install .

WORKDIR /root/code/
RUN git clone https://github.com/openai/gym-soccer.git

RUN cd gym-soccer && \
    pip install -e .

