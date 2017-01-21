{% macro nginx_auth(service, nginx) %}
{{ service.app }}-nginx-auth-htpasswd-file:
  file.managed:
    - name: {{ nginx.htpasswd_path }}/{{ service.environment.VIRTUAL_HOST }}
    - contents: {{ service.htpasswd }}
    - makedirs: True
{% endmacro %}

{% macro nginx_custom(service, nginx) %}
{% if service.nginx.custom.location is defined %}
{{ service.app }}-nginx-auth-location-file:
  file.managed:
    - name: {{ nginx.vhost_path }}/{{ service.environment.VIRTUAL_HOST }}_location
    - contents: "{{ service.nginx.custom.location }}"
    - makedirs: True
  require:
    - file: {{ service.app }}-nginx-auth-htpasswd-file
{% endif %}
{% endmacro %}

{% macro nginx_service(nginx) %}
nginx-service-config-file:
  file.managed:
    - name: {{ nginx.config_file_path }}
    - source: {{ nginx.config_file_source }}
    - makedirs: True
    - template: jinja
    - context:
        nginx_workers: {{ nginx.worker_processes }}
        nginx_client_body_buffer_size: {{ nginx.client_body_buffer_size }}
        nginx_proxy_connect_timeout: {{ nginx.proxy_connect_timeout }}
        nginx_proxy_send_timeout: {{ nginx.proxy_send_timeout }}
        nginx_proxy_read_timeout: {{ nginx.proxy_read_timeout }}
        nginx_send_timeout: {{ nginx.send_timeout }}

nginx-service-image:
  dockerng.image_present:
    - name: jwilder/nginx-proxy:latest
  require:
    - file: nginx-service-config-file

nginx-service-running:
  dockerng.running:
    - name: nginx
    - image: jwilder/nginx-proxy:latest
    - binds:
      - {{ nginx.config_file_path }}:/etc/nginx/nginx.conf:ro
      - {{ nginx.config_path }}:/etc/nginx/conf.d
      - {{ nginx.htpasswd_path }}:/etc/nginx/htpasswd:ro
      - {{ nginx.vhost_path }}:/etc/nginx/vhost.d:ro
      - {{ nginx.includes_path }}:/etc/nginx/includes:ro
      - {{ nginx.upstreams_path }}:/etc/nginx/upstreams:ro
      - {{ nginx.sites_enabled_path }}:/etc/nginx/sites-enabled:ro
      - /var/www/static/dist:/var/www/static/dist:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
    - port_bindings:
      - 80:80
    - restart_policy: always
    - force: True
  require:
    - file: nginx-service-config-file
{% endmacro %}
