#Download base ubuntu image
FROM ubuntu:24.04
RUN apt-get update && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Get Go
RUN curl -L https://go.dev/dl/go1.23.2.linux-amd64.tar.gz | tar -C /usr/local -xz

# Get dependencies
RUN apt-get -y install cmake swig3.0 python3 python3-dev python3-pip python3-venv libhwloc-dev libboost-dev libffi-dev libssl-dev

# Prepare python
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and setuptools
RUN pip3 install --upgrade pip setuptools>=80.9.0 && \
    # Remove all system setuptools packages and wheels
    apt-get -y remove python3-setuptools python3-setuptools-whl || true && \
    rm -rf /usr/lib/python3/dist-packages/setuptools* && \
    rm -rf /usr/lib/python3*/site-packages/setuptools* && \
    rm -rf /usr/share/python-wheels/setuptools-*

RUN groupadd -r qrl && useradd -r -g qrl -m -d /home/qrl -s /bin/bash qrl && \
    chown -R qrl:qrl /home/qrl && \
    chown -R qrl:qrl /usr/local/src && \
    chown -R qrl:qrl /opt/venv && \
    # Copy Rust installation to qrl user and set up environment
    cp -r /root/.cargo /home/qrl/ && \
    cp -r /root/.rustup /home/qrl/ && \
    chown -R qrl:qrl /home/qrl/.cargo /home/qrl/.rustup && \
    # Add Rust and Go to environment for both interactive and non-interactive shells
    echo 'source $HOME/.cargo/env' >> /home/qrl/.profile && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/qrl/.profile && \
    echo 'source $HOME/.cargo/env' >> /home/qrl/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/qrl/.bashrc

USER qrl
WORKDIR /home/qrl
