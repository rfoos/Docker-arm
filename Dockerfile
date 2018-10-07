# the first thing we need to do is define from what image we want to build from. 
# Here we will use a 16.04 LTS(long term support) version of ubuntu from docker Hub :
FROM ubuntu:16.04
# todo: 18.04 requires switching to gdb-multiarch. Will be moving to that shortly.

# original: MAINTAINER Mohamed Ali May "https://github.com/maydali28"
MAINTAINER Rick Foos "https://github.com/rfoos"

ARG DEBIAN_FRONTEND=noninteractive

# Fix debconf problem under Docker.
RUN apt-get update -q && apt-get install --assume-yes apt-utils
#install software requirements
RUN apt-get install --no-install-recommends -y software-properties-common build-essential git symlinks expect tcl

# Install build dependancies
RUN apt-get install -y binutils-arm-none-eabi \
                   gcc-arm-none-eabi \
                   gdb-arm-none-eabi \
                   libnewlib-arm-none-eabi

RUN apt-cache policy gcc-arm-none-eabi
# RUN apt-get install --no-install-recommends -y gcc-arm-embedded

#install Debugging dependancies
#install OPENOCD Build dependancies and gdb
RUN apt-get install --no-install-recommends -y \
        libusb-0.1-4 \
        libusb-1.0-0 libusb-1.0-0-dev \
        libusb-dev \
        libhidapi-dev \
        libhidapi-hidraw0 \
        libhidapi-libusb0 \
        libusb-1.0-0-dev \
  		libusb-dev \
        libftdi1 libftdi1-2 libftdi1-dev \
  		libtool \
  		make \
  		automake \
  		pkg-config \
        autoconf \
        texinfo \
        udev usbutils

#build and install OPENOCD from repository
# Official repo at: https://git.code.sf.net/p/openocd/code
RUN cd /usr/src/ \
    && git clone --depth 1 https://github.com/rfoos/openocd.git \
    && cd openocd \
    && ./bootstrap \
    && ./configure --enable-stlink --enable-jlink --enable-ftdi --enable-cmsis-dap \
    && make -j -l"$(nproc)" \
    && make install 
#remove unneeded directories
RUN cd ..
RUN rm -rf /usr/src/openocd \
    && rm -rf /var/lib/apt/lists/*
#OpenOCD talks to the chip through USB adapters, so we need grant our account access to the FTDI.
RUN mkdir -p  /etc/udev/rules.d/
RUN cp /usr/local/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d/60-openocd.rules
# RUN udevadm control --reload-rules && udevadm trigger

#create a directory for our project & setup a shared workfolder between the host and docker container
RUN mkdir -p /usr/src/app
VOLUME ["/usr/src/app"]
WORKDIR /usr/src/app
RUN cd /usr/src/app

EXPOSE 4444
EXPOSE 3333
