#Download base ubuntu image
FROM ubuntu:18.04
RUN apt-get update && \
    apt-get -y install software-properties-common && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget

# Upgrade Python to latest available version for Ubuntu 18.04
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get -y install python3.8 python3.8-dev python3.8-venv python3.8-distutils && \
    curl -sS https://bootstrap.pypa.io/pip/3.8/get-pip.py | python3.8 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
    update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip3.8 1

# Prepare remaining python tools and dependencies
RUN apt-get -y install swig3.0 libhwloc-dev libboost-dev

# Upgrade Werkzeug
RUN pip3 install 'Werkzeug>=3.0.0' --upgrade && \
    rm -rf /usr/lib/python3/dist-packages/werkzeug* && \
    rm -rf /usr/lib/python3/dist-packages/Werkzeug*

RUN cd /usr/local/src \
    && wget https://cmake.org/files/v3.10/cmake-3.10.3.tar.gz \
    && tar xvf cmake-3.10.3.tar.gz \
    && cd cmake-3.10.3 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*

RUN groupadd -r qrl && useradd -r -g qrl -m -d /home/qrl -s /bin/bash qrl && \
    chown -R qrl:qrl /home/qrl && \
    chown -R qrl:qrl /usr/local/src

USER qrl
WORKDIR /home/qrl
