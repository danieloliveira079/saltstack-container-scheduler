nginx:
  config_file_path: "/data/nginx/nginx.conf"
  config_path: "/data/nginx/conf.d"
  config_file_source: "salt://nginx/files/nginx.conf"
  htpasswd_path: "/data/nginx/htpasswd"
  vhost_path: "/data/nginx/vhost.d"
  includes_path: "/data/nginx/includes"
  upstreams_path: "/data/nginx/upstreams"
  sites_enabled_path: "/data/nginx/sites-enabled"

include:
{% for environment in grains['environment'] -%}
  - nginx.{{ environment }}
{% endfor -%}
