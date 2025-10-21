FROM ubuntu:24.04 as builder
ARG NJOBS=8

RUN apt update && apt install -y build-essential clang lld bison flex libfl-dev \
		libreadline-dev gawk tcl-dev libffi-dev git \
		graphviz xdot pkg-config python3 libboost-system-dev libboost-thread-dev \
		libboost-python-dev libboost-filesystem-dev libboost-program-options-dev \
    zlib1g-dev cmake python3-dev libeigen3-dev libboost-iostreams-dev

RUN git clone --recurse-submodules -b v0.58 https://github.com/YosysHQ/yosys.git && cd yosys && make -j $NJOBS && make install 

RUN git clone --recursive -b machxo3d-i3c-pins https://github.com/via/prjtrellis && cd prjtrellis/libtrellis && cmake . && make -j $NJOBS && make install

RUN git clone --recursive https://github.com/YosysHQ/nextpnr.git && cd nextpnr && cmake . -B build -DARCH=machxo2 -DMACHXO2_DEVICES="9400D" &&  cd build && make -j $NJOBS && make install

# Strip debug symbols
RUN strip /usr/local/bin/* || /usr/bin/true

FROM ubuntu:24.04
RUN apt update && apt install -y libfl2 libreadline8t64 tcl libffi8 \
  libpython3.12-dev libboost-system1.83.0 libboost-thread1.83.0 \
  libboost-python1.83.0  libboost-filesystem1.83.0 \
  libboost-program-options1.83.0 libboost-iostreams1.83.0 zlib1g
COPY --from=builder /usr/local/ /usr/local/

