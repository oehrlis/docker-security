---
title: "Demo Docker Security"
subtitle: "Demos of the lecture Docker Security"
author: [Stefan Oehrli]
date: "20 Dezember 2018"
tvddocversion: 1.0
papersize: a4 
listings-disable-line-numbers: true
titlepage: true
toc: true
toc-own-page: true
toc-title: "Inhalt"
toc-depth: 2
linkcolor: blue
---

# Demo Docker Security

## Requirements and Environment

All demos are done on Docker Community Edition 18.03.1 on Oracle Linux 7.5 running on a virtualbox VM created based on Vagrant. The examples are supposed to run on all Docker environments on Linux. Below we just provide the steps to setup the demo environment based on an Oracle Vagrant box for Docker. (see [oracle/vagrant-boxes](https://github.com/oracle/vagrant-boxes) on GitHub).

### Prerequisites

1. Install [Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://vagrantup.com/)
3. Clone the docker setup demo respoistory `git clone https://github.com/oehrlis/docker-security`
4. Provisions a vagrant environment.
5. Configure the VM for the demos.

Alternatively you can use the scripts from the repository on you own Docker environment.

## Setup demo environment

**Step 1:** Clone the Oracle vagrantbox respoistory

```bash
git clone https://github.com/oehrlis/docker-security
```

**Step 2:** Provisions a vagrant environment

```bash
vagrant up
vagrant ssh
```

**Step 3:** Predownload a couple of images

```bash
docker pull alpine
docker pull centos:7
docker pull ubuntu:17.10
docker pull oraclelinux
```

## Update Host

The **alpine:demo** container is a small example Container with just a scripts.

Docker file for this small demo:

``` bash
# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.03.19
# Revision...: 1.0
# Purpose....: This Dockerfile for a Docker Security Demo
# Notes......: --
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ----------------------------------------------------------------------

# Pull base image
# ----------------------------------------------------------------------
FROM alpine

# Maintainer
# ----------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@trivadis.com"

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV DOCKER_SCRIPTS="/opt/docker/bin" \
    START_SCRIPT="start_system_update.sh"

ENV PATH=${PATH}:"${DOCKER_SCRIPTS}"

# copy all setup scripts to DOCKER_BIN
COPY scripts/* "${DOCKER_SCRIPTS}/"

# Define default command to start OUD instance
CMD exec "${DOCKER_SCRIPTS}/${START_SCRIPT}"
```

Or the short form...

```Dockerfile
FROM alpine
LABEL maintainer="stefan.oehrli@trivadis.com"
COPY scripts/* "/opt/docker/bin"
CMD exec "/opt/docker/bin/start_system_update.sh"
```

Build the test container

``` bash
cd $HOME/demo/update_host
docker build -t alpine:demo00 .
```

Run it to "start the Demo App" :-)

```bash
docker container run -d -v /:/h --name demo alpine:demo00

docker container run -it -v /:/h --rm alpine:demo00 sh
```

Check if it is still running

```bash
docker ps
```

Check the logs...

```bash
docker logs demo

docker rm demo
```

login as *toor* using *ssh*.
```bash
ssh toor@urania
```

remove toor again....

```bash
docker run --rm -v /:/h alpine:demo00 sed -i '/^toor/d' /h/etc/passwd
docker run --rm -v /:/h alpine:demo00 sed -i '/^toor/d' /h/etc/shadow
```

## Linux Namespaces

Create a simple container with does run ping ([one ping only vasili](https://youtu.be/jr0JaXfKj68) )

``` bash
docker container run --rm -d \
    --name vasili \
    -v /tmp:/data1 \
    alpine ping 127.0.0.1
```

Check what's going on
``` bash
docker logs -f vasili
docker ps
docker container top vasili
```

Just run a bash shell

``` bash
docker container run --rm -it \
    --name sample \
    -v /tmp:/data2 \
    centos:7 /bin/bash --login --posix
```

Check the PID's in an other terminal

check the OS
```bash
ps -ef|grep -i ping
PID=$(ps -ef|grep -i ping|grep -iv grep |sed 's/\s\s*/ /g' | cut -d' ' -f2)
sudo nsenter --target $PID --pid --mount sleep 300 &
sudo nsenter --target $PID --pid --mount ps aux
sudo nsenter --target $PID --pid --mount kill -9 8
sudo nsenter --target $PID --pid --mount cat /proc/mounts | grep '^/dev'

pstree -a -H $PID
```

Stop everthing

```bash
docker stop sample
docker stop vasili
```

## Resources

Create a directory and a Dockerfile.
```bash
mkdir -p $HOME/docker/cgroups
cd $HOME/demo/cgroups
vi Dockerfile
```

Create a Dockerfile with the following content.

```Dockerfile
FROM ubuntu:17.10
RUN apt-get update && apt-get install -y stress
ENTRYPOINT ["stress"]
CMD ["-c", "2", "--timeout", "15"]
```

Build the image...

```bash
cd $HOME/demo/cgroups
docker image build -t stress_demo .
```

open a new terminal and start htop-

```bash
htop
```

Run the image and check what's happen.

```bash
docker container run --rm -d stress_demo
```

Start the *stress_demo* and limit the CPU.

```bash
docker container run --rm -d --cpuset-cpus 0 stress_demo
```

Start the *stress_demo* without any memory limit.

```bash
docker container run --rm -d \
    stress_demo --vm 1 --vm-bytes 2048M --timeout 15
```

Start the *stress_demo* with an upper memory limit.

```bash
docker container run --rm -d \
    --memory 256m \
    stress_demo --vm 1 --vm-bytes 2048M --timeout 15
```

## Build ENV

Create a file / folder

```bash
mkdir -p $HOME/demo/passwords
cd $HOME/demo/passwords

echo "Hallo World, demo 2018" >demo.txt
```

Create a Dockerfile with the following content.

```Dockerfile
FROM alpine
ENV URL=http://docker.oradba.ch/depot/demo.zip \
    USER=scott \
    PASSWORD=tiger
RUN apk --update add curl && \
    curl --user scott:tiger -f $URL -o demo.txt
RUN curl --user $USER:$PASSWORD -f $URL -o demo.txt
CMD cat demo.txt
```

Build the demo01 image.

```bash
docker build -t alpine:demo01 .
```

Check the image history

```bash
docker history alpine:demo01
docker history --no-trunc alpine:demo01
```

## SECCOMP 

```bash
cat /boot/config-`uname -r` | grep CONFIG_SECCOMP=
```

http://bit.ly/2j8Bihr

## Show SELinux

Check if SELinux is enforced

```bash
getenforce
sudo setenforce 1
docker system info
```

Enable SELinux in Docker service file

```bash
sudo vi /usr/lib/systemd/system/docker.service

ExecStart=/usr/bin/dockerd --selinux-enabled
ExecStart=/usr/bin/dockerd
```

Restart the docker service

```bash
sudo systemctl stop docker
sudo systemctl daemon-reload
sudo systemctl start docker
```

Check Docker system info again

```bash
docker system info
```

Try the Demo App...

```bash
docker container run -d -v /:/h --name demo alpine:demo
docker logs demo
```

Clean up and remove the demo container

```bash
docker rm demo
```
