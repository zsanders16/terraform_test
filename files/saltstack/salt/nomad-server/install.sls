{% set NOMAD_VERSION = "0.8.6" %}

nomad_binary_download:
  cmd.run:
    - name: wget -O /tmp/nomad.zip https://releases.hashicorp.com/nomad/{{ NOMAD_VERSION }}/nomad_{{ NOMAD_VERSION }}_linux_amd64.zip && unzip -o /tmp/nomad.zip -d /usr/local/bin
    - unless:
      - "nomad version | grep {{ NOMAD_VERSION }}"
      - "test -f /usr/local/bin/nomad"
    - require:
      - pkg: nomad_prequsistes_package


install_nomad_service:
  file.managed:
    - name: /etc/systemd/system/nomad.service
    - source: salt://nomad-server/files/nomad.service

install_nomad_config:
  file.managed:
    - name: /tmp/server.hcl
    - source: salt://nomad-server/files/server.hcl

nomad:
  service.running:
    - enable: True