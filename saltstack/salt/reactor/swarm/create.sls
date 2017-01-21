{% set postdata = data.get('post', {}) %}
{% if postdata.secretkey is defined and postdata.secretkey == "JHc3pJDMwRCmVVTw1nqEY9zPNDUJ2gzY6cXvOL17fHgO" %}
swarm_service_create:
  local.state.apply:
    - tgt: "G@roles:swarmmanager"
    - expr_form: compound
    - arg:
      - "swarm.service.create"
    - kwarg:
        pillar:
          postdata: {{ postdata | json() }}
          {% if postdata.environment is defined %}
          environment: {{ postdata.environment }}
          {% endif %}
        queue: True
{% endif %}
