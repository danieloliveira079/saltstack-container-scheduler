base:
  '*':
    - common
  'swarmmanager':
    - match: nodegroup
    - docker.engine
    - swarm.manager.mine
    - swarm.manager.drain
  'swarmworker':
    - match: nodegroup
    - docker.engine
