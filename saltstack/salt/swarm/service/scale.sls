{% from 'templates/swarm.sls' import scale_swarm_service with context %}
{%- from "swarm/service/map.jinja" import replicas, service_name with context %}

{{ scale_swarm_service(service_name, replicas) }}
