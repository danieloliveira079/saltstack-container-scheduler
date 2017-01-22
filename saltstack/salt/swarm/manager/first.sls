include:
  - docker.engine

swarm_manager_cluster_init:
  cmd.run:
    - name: 'docker swarm init --advertise-addr eth1'
    - require:
      - pkg: docker-engine
