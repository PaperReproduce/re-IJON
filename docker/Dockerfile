FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python \
    python3 \
    python3-pip \
    ruby \
    clang-6.0 \
    llvm-6.0 \
    llvm-6.0-dev \
    llvm-6.0-tools \
    cmake \
    pkg-config \
    libsdl2-dev \
    libboost-all-dev \
    libglib2.0-dev \
    libpixman-1-dev \
    flex \
    bison \
    autoconf \
    automake \
    libtool \
    libssl-dev \
    liblzma-dev \
    zlib1g-dev \
    gcc-multilib \
    g++-multilib \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/clang-6.0 /usr/bin/clang && \
    ln -sf /usr/bin/clang++-6.0 /usr/bin/clang++ && \
    ln -sf /usr/bin/llvm-config-6.0 /usr/bin/llvm-config

WORKDIR /workspace

COPY . /workspace

ENV AFL_PATH=/workspace/repos/ijon \
    LLVM_CONFIG=llvm-config-6.0 \
    CC=clang-6.0 \
    CXX=clang++-6.0

RUN cd repos/ijon && \
    make clean && \
    CC=${CC} make all && \
    cd llvm_mode && \
    LLVM_CONFIG=${LLVM_CONFIG} CC=${CC} make ../afl-clang-fast ../afl-llvm-pass.so ../afl-llvm-rt.o ../afl-llvm-rt-32.o ../afl-llvm-rt-64.o

CMD ["/bin/bash"]
