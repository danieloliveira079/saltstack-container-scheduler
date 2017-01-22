{% macro git_clone(app, fingerprint, repo, branch, dest_folder) %}
{{ app }}-git:
  pkg.installed:
    - name: git

{{ app }}-gitlab.ssh:
  ssh_known_hosts:
    - present
    - name: gitlab.mydomain.com
    - user: root
    - enc: ecdsa-sha2-nistp256
    - fingerprint: {{ fingerprint }}

{{ app }}-git-clone-app:
  git.latest:
    - name: {{ repo }}
    - rev: {{ branch }}
    - target: {{ dest_folder }}
    - submodules: True
    - identity: /root/.ssh/id_rsa
    - require:
        - pkg: git
        - ssh_known_hosts: {{ app }}-gitlab.ssh
{% endmacro %}
