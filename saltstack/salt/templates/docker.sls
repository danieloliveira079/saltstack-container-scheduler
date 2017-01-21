{% macro build_image(app, dest_folder, image_name, postdata, build_args) %}
{{ app }}-docker-image-absent:
  dockerng.image_absent:
    - images:
      - {{ image_name }}:{{ postdata.buildinfo.tag }}
    - force: True

{{ app }}-docker-image-present:
  cmd.run:
    - name: "docker build --quiet --force-rm
                    {% if build_args is defined %}
                    {%- for key, value in build_args.iteritems() -%}
                    --build-arg {{ key }}={{ value }}
                    {% endfor -%}
                    {% endif -%}
                    -t {{ image_name }}:{{ postdata.buildinfo.tag }} {{ dest_folder }}"
    - cwd: {{ dest_folder }}

{{ app }}-dest-folder:
  file.absent:
    - name: {{ dest_folder }}
  require:
    - cmd: {{ app }}-docker-image-present
{% endmacro %}

{% macro deploy_container_app(app, container_name, image_name, tag_name, force, ports, environment, syslog) %}
{{ app }}-container-remove:
  dockerng.absent:
    - name: {{ container_name }}
    - force: force

{{ app }}-container-running:
  cmd.run:
    - name: "docker run -d --name {{ container_name }}
                        {%- if 'staging' in grains['environment'] or grains['syslog'] is defined %}
                        --log-driver=syslog
                        --log-opt tag={{ '{{.Name}}' }}
                        --log-opt syslog-address={{ syslog.url }}
                        {%- endif %}
                        --restart=always
                        {%- if ports is defined %}
                        {% for item in ports -%}
                        --expose '{{ item }}'
                        {% endfor -%}
                        {% endif -%}
                        {% if environment is defined %}
                        {%- for key, value in environment.iteritems() -%}
                        -e {{ key }}={{ value }}
                        {% endfor -%}
                        {% endif -%}
                        {{ image_name }}:{{ tag_name }}"
{% endmacro %}

{% macro deploy_container_service(app, container_name, image_name, tag_name, command, force, environment, port, expose, volume, links) %}
{{ image_name }}:{{ tag_name }}:
  dockerng.image_present

{{ app }}-service-running:
  dockerng.running:
    - name: {{ container_name }}
    - image: {{ image_name }}:{{ tag_name }}
    {% if command is defined %}
    - command: {{ command }}
    {% endif %}
    - restart_policy: always
    - force: {{ force }}
    {% if links is defined %}
    - links: {{ links }}
    {% endif %}
    {% if expose is defined %}
    - ports: {{ expose }}
    {% endif %}
    {% if port is defined %}
    - port_bindings: {{ port }}
    {% endif %}
    {% if volume is defined %}
    - binds: {{ volume }}
    {% endif %}
    {% if environment is defined %}
    - environment: {{ environment }}
    {% endif %}
{% endmacro %}

{% macro remove_unused_image(images) %}
docker-remove-image:
{% if images is defined %}
  cmd.run:
    - names:
      {% for image in images %}
      - docker rmi {{ image }}
      {% endfor %}
{% else %}
  cmd.run:
    - name: docker rmi $(docker images -q)
{% endif %}
{% endmacro %}

{% macro push_image(app, repo, image_name, image_tag) %}
{% if salt['pillar.get']('docker_use_private_registry', False) == True %}
{{ app }}-authenticate-to-registry:
  cmd.run:
    - name: docker login -u {{ repo.username }} -p {{ repo.password }} {{ repo.name }}

{{ app }}-push-image-to-registry:
  cmd.run:
    - name: docker push {{ image_name }}:{{ image_tag }}
  require:
    - cmd: {{ app }}-authenticate-to-registry

{{ app }}-logout-registry:
  cmd.run:
    - name: docker logout
  require:
    - dockerng: {{ app }}-authenticate-to-registry
{% endif %}
{% endmacro %}

# This is the approaching using Salt Dockerng module which is expecting for the new release that will support Log Driver
{% macro deploy_container_deprecated(app, container_name, image_name, tag_name, force, ports, environment) %}
{{ image_name }}:{{ tag_name }}:
  dockerng.image_present

{{ app }}-container-running:
  dockerng.running:
    - name: {{ container_name }}
    - image: {{ image_name }}:{{ tag_name }}
    - force: {{ force }}
    - restart_policy: always
    - ports:
      {% for item in ports -%}
      - {{ item }}
      {% endfor %}
    {% if environment is defined %}
    - environment: {{ environment }}
    {% endif %}
    - log_config:
        Type: syslog
        Config:
          syslog-facility: local6
          syslog-tag: my_tag
{% endmacro %}
