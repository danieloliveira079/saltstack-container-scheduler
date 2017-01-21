swarm_manager_active:
  cmd.run:
    - name: 'docker node update --availability active {{ grains['id'] }}'
