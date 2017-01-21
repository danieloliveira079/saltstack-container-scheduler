docker-python-apt:
  pkg.installed:
    - name: python-apt

purge-old-packages:
  pkgrepo.absent:
    - name: deb https://get.docker.com/ubuntu docker main
  pkg.purged:
    - name: lxc-docker*
    - require_in:
      - pkgrepo: docker-repository

docker-dependencies:
   pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - apparmor
      - linux-image-extra-{{ grains.get('kernelrelease') }}

docker-repository:
  pkgrepo.managed:
    - name: deb https://apt.dockerproject.org/repo {{ grains["os"]|lower }}-{{ grains["oscodename"] }} main
    - humanname: {{ grains["os"] }} {{ grains["oscodename"]|capitalize }} Docker Package Repository
    - keyid: 58118E89F3A912897C070ADBF76221572C52609D
    - keyserver: keyserver.ubuntu.com
    - file: /etc/apt/sources.list.d/docker.list
    - refresh_db: True
    - require_in:
      - pkg: docker-package
    - require:
      - pkg: docker-dependencies

docker-package:
  pkg.installed:
    - name: docker-engine

docker-service:
  service.running:
    - name: docker
    - enable: True
    - watch:
      - pkg: docker-package
    - require:
      - pkg: docker-engine  
