FROM ubuntu:16.04

MAINTAINER Daniel Oliveira

RUN apt-get update && apt-get install -y wget && wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - && \
    echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list && \
    apt-get update && apt-get upgrade -y -o DPkg::Options::=--force-confold

# Add the Salt PPA
RUN apt-get install -y -o DPkg::Options::=--force-confold apt-utils python-software-properties software-properties-common && \
  apt-get update

# Install Salt Dependencies
RUN apt-get install -y -o DPkg::Options::=--force-confold \
  python \
  python-yaml \
  python-m2crypto \
  python-crypto \
  msgpack-python \
  python-zmq \
  python-jinja2 \
  python-requests

RUN apt-get install -y salt-master
