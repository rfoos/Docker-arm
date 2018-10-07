# Docker-arm

This repository contains source code for the article
https://dev.to/dalimay28/using-docker-for-embedded-systems-development-b16

This fork updates this to 16.04 tools, and a custom version of OpenOCD.
OpenOCD is up to date. The additions are staged review at 

Contents:

1.Dockerfile 

2.example for ECM3531 from ETA Compute.

## How to setup The environment :

```
cd ~
sudo apt-get install git 
git clone https://github.com/rfoos/Docker-arm/
cd ~/Docker-arm
```

## Usage :

#### Build the image :

```
cd ~/Docker-arm--enable-stlink --enable-jlink --enable-ftdi --enable-cmsis-dap
docker build -t docker-arm .
```

#### run the container :

```
cd ~/Docker-arm
docker run -it --name docker-arm -p 4444:4444 -v "$(pwd)/app":/usr/src/app --privileged -v /dev/bus/usb:/dev/bus/usb docker-arm /bin/bash
```

#### build existing Project :

see more steps in https://github.com/rowol/stm32_discovery_arm_gcc/blob/master/README.md
```
cd /usr/src/app
cd blinky
make
```

### flash code into the board:

openocd -s "/usr/local/share/openocd/scripts" -f "interface/stlink-v2.cfg" -f "target/stm32f4x.cfg" -c "main main.elf verify reset exit"

#### debugging existing project

Run Openocd as GDB server 
```
openocd -c "gdb_port 4444" -s "/usr/local/share/openocd/scripts" -f "interface/stlink-v2.cfg" -f "target/stm32f4x.cfg"

```
Open another terminal and run
```
docker exec -it docker-arm /bin/bash
arm-none-eabi-gdb blinky.elf
gdb) target remote localhost:4444
gdb) load
```
