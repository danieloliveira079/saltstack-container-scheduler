{% from 'templates/swarm.sls' import deploy_swarm_service with context %}
{%- from "swarm/service/map.jinja" import service with context %}

{{ deploy_swarm_service(service.scheduler.service_name, service.scheduler.service_port, service.scheduler.options, service.environment, service.scheduler.image_name, service.scheduler.tag) }}
