#Download base ubuntu image
FROM ubuntu:16.04

RUN apt-get update
RUN apt-get -y install software-properties-common python-software-properties
RUN apt-get -y install ca-certificates curl
RUN apt-get -y install build-essential pkg-config git sudo wget

# Install python3-pip and upgrade PyYAML
RUN apt-get -y install python3-pip && \
    pip3 install 'PyYAML>=5.1,<6.0' --upgrade && \
    rm -rf /usr/lib/python3/dist-packages/PyYAML-3.11.egg-info && \
    rm -rf /usr/lib/python3/dist-packages/yaml && \
    rm -f /usr/lib/python3/dist-packages/_yaml.cpython-35m-*-linux-gnu.so

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
