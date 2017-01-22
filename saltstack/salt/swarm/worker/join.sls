{% set join_token = salt['mine.get']('*', 'worker_token').items()[0][1] %}
{% set join_ip = salt['mine.get']('*', 'manager_ip').items()[0][1][0] %}

include:
  - docker.engine
  
swarm_manager_cluster_join:
  cmd.run:
    - name: 'docker swarm join --token {{ join_token }} {{ join_ip }}:2377'
