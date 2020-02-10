#Download base ubuntu image
FROM ubuntu:16.04
SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt-get -y install swig3.0 \
                      python3-dev \
                      python3-pip \
                      build-essential \
                      pkg-config \
                      libssl-dev \
                      libffi-dev \
                      libhwloc-dev \
                      libboost-dev \
                      wget \
                      curl \
                      git

RUN pip3 install --upgrade pip virtualenv setuptools twine PyScaffold

# Install nodejs
RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash

RUN echo "ALL ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN cd ${HOME} && git clone https://github.com/emscripten-core/emsdk.git && cd emsdk && git pull

RUN cd ${HOME}/emsdk && ./emsdk install latest
RUN cd ${HOME}/emsdk && ./emsdk activate latest
RUN cd ${HOME}/emsdk && source ./emsdk_env.sh
