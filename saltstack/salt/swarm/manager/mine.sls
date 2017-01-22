/etc/salt/minion.d/swarm.conf:
  file.managed:
    - source: salt://swarm/files/swarm.conf
