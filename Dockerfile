#Download base ubuntu image
FROM ubuntu:24.04
RUN apt-get update && \
    apt-get -y install ca-certificates curl && \
    apt-get -y install build-essential pkg-config git sudo wget

# Install Playwright system dependencies
RUN apt-get install -y \
    libnss3 \
    libnspr4 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libasound2 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Get Go
RUN curl -L https://go.dev/dl/go1.25.3.linux-amd64.tar.gz | tar -C /usr/local -xz

# Get dependencies
RUN apt-get -y install cmake swig3.0 python3 python3-dev python3-pip python3-venv libhwloc-dev libboost-dev libffi-dev libssl-dev

# Get Emscripten SDK
RUN git clone https://github.com/emscripten-core/emsdk.git /usr/local/emsdk && \
    cd /usr/local/emsdk && \
    ./emsdk install latest && \
    ./emsdk activate latest

# Prepare python
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set up Go and Rust paths for all shells (including CI)
ENV PATH="/usr/local/go/bin:$PATH"

# Set up Emscripten environment
ENV EMSDK="/usr/local/emsdk"
ENV PATH="$EMSDK:$EMSDK/upstream/emscripten:$EMSDK/node/22.16.0_64bit/bin:$PATH"

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
    chown -R qrl:qrl /usr/local/emsdk && \
    # Copy only essential Rust components (skip documentation)
    mkdir -p /home/qrl/.cargo /home/qrl/.rustup && \
    cp -r /root/.cargo/bin /home/qrl/.cargo/ && \
    cp -r /root/.cargo/env /home/qrl/.cargo/ && \
    cp -r /root/.rustup/settings.toml /home/qrl/.rustup/ 2>/dev/null || true && \
    cp -r /root/.rustup/toolchains /home/qrl/.rustup/ && \
    # Remove documentation to save space
    find /home/qrl/.rustup -name "doc" -type d -exec rm -rf {} + 2>/dev/null || true && \
    chown -R qrl:qrl /home/qrl/.cargo /home/qrl/.rustup

# Set environment variables for qrl user (for CI compatibility)
USER qrl
ENV PATH="/home/qrl/.cargo/bin:$PATH"
ENV CARGO_HOME="/home/qrl/.cargo"
ENV RUSTUP_HOME="/home/qrl/.rustup"
# Emscripten environment for qrl user
ENV EMSDK="/usr/local/emsdk"
ENV PATH="$EMSDK:$EMSDK/upstream/emscripten:$EMSDK/node/22.16.0_64bit/bin:$PATH"

# Source emsdk environment in bashrc for interactive use
RUN echo 'source /usr/local/emsdk/emsdk_env.sh' >> /home/qrl/.bashrc

WORKDIR /home/qrl

# Install Playwright and browsers as user qrl
RUN npm install -g playwright@latest \
    && npx playwright install chromium
