{%- from "nginx/map.jinja" import nginx with context %}
{% from 'templates/nginx.sls' import nginx_auth, nginx_service with context %}

{{ nginx_service(nginx) }}
