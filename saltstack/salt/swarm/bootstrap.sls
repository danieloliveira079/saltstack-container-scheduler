# salt-run state.orchestrate swarm.bootstrap

{% for manager in salt['saltutil.runner']('cache.grains', tgt='swarmmanager', expr_form='nodegroup') %}

{% if loop.first %}
{% set manager_sls = 'swarm.manager.first' %}
{% else %}
{% set manager_sls = 'swarm.manager.join' %}
{% endif %}

swarm_manager_bootstrap_{{ manager }}:
  salt.state:
    - sls: {{ manager_sls }}
    - tgt: {{ manager }}

swarm_manager_bootstrap_drain{{ manager }}:
  salt.state:
    - sls: 'swarm.manager.drain'
    - tgt: {{ manager }}

swarm_manager_update_mine_{{ manager }}:
  salt.function:
    - name: mine.update
    - tgt: '*'
    - require:
      - salt: swarm_manager_bootstrap_{{ manager }}
{% endfor %}

{% for worker in salt['saltutil.runner']('cache.grains', tgt='swarmworker', expr_form='nodegroup') %}
swarm_worker_bootstrap_{{ worker }}:
  salt.state:
    - sls: swarm.worker.join
    - tgt: {{ worker }}
{% endfor %}
