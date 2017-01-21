{% macro create_dir(app, dest_folder) %}
{{ app }}-destination-folder:
  file.directory:
    - name: {{ dest_folder }}
    - mode: 755
    - makedirs: True
{% endmacro %}
