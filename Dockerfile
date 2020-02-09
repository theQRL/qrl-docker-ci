#Download base ubuntu image
FROM ubuntu:14.04
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get -y install software-properties-common python-software-properties && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    add-apt-repository -y ppa:tigerite/mint-xorg-update && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update

# Prepare python
RUN apt-get update && apt-get -y install swig3.0 libhwloc-dev libboost-dev libffi-dev python3-dev python3-pip python3-tk python3-lxml python3-six

# PyEnv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
# Configure Python not to try to write .pyc files on the import of source modules
ENV PYTHONDONTWRITEBYTECODE true
ENV PYTHON_VERSION 3.6.2

RUN sudo apt-get update -q \
    && sudo apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        zlib1g-dev

# Install pyenv and default python version
RUN git clone https://github.com/yyuu/pyenv.git /root/.pyenv \
    && cd /root/.pyenv \
    && git checkout `git describe --abbrev=0 --tags` \
    && sudo echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc \
    && sudo echo 'eval "$(pyenv init -)"'               >> ~/.bashrc

RUN pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION

RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools
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
