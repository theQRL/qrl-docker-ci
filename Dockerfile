#Download base ubuntu image
FROM ubuntu:14.04

RUN apt-get update && \
    apt-get -y install software-properties-common python-software-properties && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    add-apt-repository -y ppa:tigerite/mint-xorg-update && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update

# Prepare python
RUN apt-get -y install swig3.0 python3.5 python3.5-dev python3-pip libhwloc-dev libboost-dev

RUN pip3 install --upgrade pip setuptools
RUN pip3 install --ignore-installed six

# install cmake v 3.10.3
RUN cd /usr/local/src \
    && wget https://cmake.org/files/v3.10/cmake-3.10.3.tar.gz \
    && tar xvf cmake-3.10.3.tar.gz \
    && cd cmake-3.10.3 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*
RUN cmake --version

RUN pip3 install -U -r https://raw.githubusercontent.com/theQRL/QRL/master/requirements.txt
RUN pip3 install -U -r https://raw.githubusercontent.com/theQRL/QRL/master/test-requirements.txt

# This is specificfot 
RUN echo "ALL ALL=NOPASSWD: ALL" >> /etc/sudoers
