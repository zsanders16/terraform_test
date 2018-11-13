{% set CONSUL_TEMPLATE_VERSION = "0.19.5" %}
{% if salt['grains.get']('os') == 'Windows' %}
{% set install_source_consul_template = 'https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_windows_amd64.zip' %}

download_zip_consul-template:
  file.managed:
    - name: C:\\consul\\consul-template_0.19.5_windows_amd64.zip
    - source: {{ install_source_consul_template }}
    - source_hash: 01a2d2979623efb95067251b569cc2020b36fbfafdca0e9cd6b4fb7f14805712
    - makedirs: True

extract_consul-template:
  module.run:
  - name: archive.unzip
  - zip_file: 'C:\\consul\\consul-template_0.19.5_windows_amd64.zip'
  - dest: 'C:\\consul\template'

consul-template_install_windows_service:
  cmd.run:
    - name: 'nssm install consul-template-agent C:\consul\template\consul-template.exe -config=C:\consul\conf\agent.hcl'
    - unless: 'sc query consul-template-agent'

consul-template-agent:
  service.running:
    - enable: True

{% endif %}

{% if salt['grains.get']('os') == 'Ubuntu' %}

consul_templates_download:
  cmd.run:
    - name: wget -O /tmp/consul-template.zip https://releases.hashicorp.com/consul-template/{{ CONSUL_TEMPLATE_VERSION }}/consul-template_{{ CONSUL_TEMPLATE_VERSION }}_linux_amd64.zip && unzip -o /tmp/consul-template.zip -d /usr/local/bin
    - unless:
      - "consul-template -v | grep {{ CONSUL_TEMPLATE_VERSION }}"
      - "test -f /usr/local/bin/consul"
    - require:
      - pkg: consul_prequsistes_package

setup_consul_serviced:
  file.managed:
    - name: /etc/systemd/system/consul.service
    - source: salt://consul-agent/files/consul.service
    - makedirs: True

setup_consul_template_serviced:
  file.managed:
    - name: /etc/systemd/system/consul-template-agent.service
    - source: salt://consul-agent/files/consul-template-agent.service
    - makedirs: True


{% endif %}