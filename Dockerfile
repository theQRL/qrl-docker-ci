#Download base ubuntu image
FROM ubuntu:16.04
RUN apt-get update && \
    apt-get -y install software-properties-common python-software-properties && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget

# Prepare python
RUN apt-get -y install swig3.0 python3 python3-dev python3-pip python3-venv libhwloc-dev libboost-dev

RUN cd /usr/local/src \
    && wget https://cmake.org/files/v3.10/cmake-3.10.3.tar.gz \
    && tar xvf cmake-3.10.3.tar.gz \
    && cd cmake-3.10.3 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*
