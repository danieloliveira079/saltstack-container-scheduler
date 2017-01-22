{% macro generate_node_cache(app, cache_folder, dest_folder) %}
{{ app }}-fetch-node-modules:
  cmd.run:
    - name: docker run --rm --name zombie-node-cache -v {{ cache_folder }}:/usr/src/app/node_modules -v {{ dest_folder }}:/usr/src/app -w /usr/src/app node:6.3 npm install --unsafe-perm
    - unless: ls {{ cache_folder }}

{{ app }}-copy-node-modules-from-cache:
  cmd.run:
    - name: cp -R {{ cache_folder }} {{ dest_folder }}
{% endmacro %}
