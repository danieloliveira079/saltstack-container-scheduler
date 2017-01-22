swarm_manager_drain:
  cmd.run:
    - name: 'docker node update --availability drain {{ grains['id'] }}'
