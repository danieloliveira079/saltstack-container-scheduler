common_packages:
  pkg.installed:
    - pkgs:
      - htop
      - vim

purge-pip:
  pkg.purged:
    - name: python-pip

python-setuptools:
  pkg.installed:
  - require:
    - pkg: python-pip

pip-install:
  cmd.run:
    - name: easy_install pip
    - require:
      - pkg: python-setuptools

docker-py:
  cmd.run:
    - name: pip install docker-py==1.7.2
    - reload_modules: True
    - require:
      - cmd: pip-install
