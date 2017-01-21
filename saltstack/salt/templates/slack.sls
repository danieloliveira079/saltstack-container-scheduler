{% macro notify_slack(app, action, channel, from, message, api_key, icon) %}
{{ app }}-slack-{{ action }}:
  slack.post_message:
    - channel: "{{ channel }}"
    - from_name: {{ from }}
    - message: "{{ message }}"
    - api_key: {{ api_key }}
    - icon: {{ icon }}
{% endmacro %}
