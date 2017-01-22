{% macro scale_swarm_service(service_name, replicas) %}
{{ service_name }}-scale-swarm-service:
  cmd.run:
    - name: docker service scale {{ service_name }}={{ replicas }}
{% endmacro %}

{% macro deploy_swarm_service(service_name, port, options, environment, image, tag) %}
{{ service_name }}-update-swarm-service:
  cmd.run:
    - name: docker service update
            {%- if port is defined %}
            --publish-add {{ port }}
            {%- endif %}
            {% if options is defined and options.update is defined %}
              {%- for key, option in options.iteritems() -%}
                {%- if key=="update" -%}
                  {%- for value in option -%}
                      {{ value }}
                  {% endfor -%}
                {% endif -%}
              {% endfor -%}
            {% endif -%}
            {% if environment is defined %}
            {%- for key, value in environment.iteritems() -%}
            --env-add {{ key }}={{ value }}
            {% endfor -%}
            {% endif -%}
            --image "{{ image }}:{{ tag }}"
            {{ service_name }}
    - onlyif: docker service ls | grep {{ service_name }}

{{ service_name }}-create-swarm-service:
  cmd.run:
    - names:
        - docker service create --name {{ service_name }}
          {%- if port is defined %}
          --publish {{ port }}
          {%- endif %}
          {% if options is defined and options.create is defined %}
            {%- for key, option in options.iteritems() -%}
              {%- if key=="create" -%}
                {%- for value in option -%}
                    {{ value }}
                {% endfor -%}
              {% endif -%}
            {% endfor -%}
          {% endif -%}
          {% if environment is defined %}
          {%- for key, value in environment.iteritems() -%}
          --env {{ key }}={{ value }}
          {% endfor -%}
          {% endif -%}
          "{{ image }}:{{ tag }}"
    - unless: docker service ls | grep {{ service_name }}
{% endmacro %}
