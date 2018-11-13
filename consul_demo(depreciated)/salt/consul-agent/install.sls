{% set CONSUL_VERSION = "1.4.0-rc1" %}
{% set CONSUL_TEMPLATE_VERSION = "0.19.5" %}
{% if salt['grains.get']('os') == 'Windows' %}
{% set install_source = 'https://releases.hashicorp.com/consul/1.2.3/consul_1.2.3_windows_amd64.zip' %}

download_zip:
  file.managed:
    - name: C:\\consul\\consul_1.2.3_windows_amd64.zip
    - source: {{ install_source }}
    - source_hash: 5c2a8842471ba0d68872ccd3d54c7baae97e52cfd69006a2f7c1a6be0cf3c650
    - makedirs: True

extract_consul:
  module.run:
  - name: archive.unzip
  - zip_file: 'C:\\consul\\consul_1.2.3_windows_amd64.zip'
  - dest: 'C:\\consul\agent'
  - require:
    - download_zip

C:\\consul\\conf\\client.json:
  file.managed:
    - source: salt://consul-agent/files/client.json
    - makedirs: True

consul_install_windows_service:
  cmd.run:
    - name: 'sc create consul-agent start= delayed-auto binPath= "c:\consul\agent\consul.exe agent -advertise 172.20.20.41 -config-file C:\consul\conf\client.json" DisplayName= "ConsulAgent"'
    # - name: 'sc create consul-agent start= delayed-auto binPath= c:\consul\agent\consul.exe -config-file C:\consul\conf\client.json DisplayName= "Consul Agent"'
    - unless: 'sc query consul-agent'

consul-agent:
  service.running:
    - enable: True

{% endif %}

{% if salt['grains.get']('os') == 'Ubuntu' %}

consul_binary_download:
  cmd.run:
    - name: wget -O /tmp/consul.zip https://releases.hashicorp.com/consul/{{ CONSUL_VERSION }}/consul_{{ CONSUL_VERSION }}_linux_amd64.zip && unzip -o /tmp/consul.zip -d /usr/local/bin
    - unless:
      - "consul version | grep {{ CONSUL_VERSION }}"
      - "test -f /usr/local/bin/consul"
    - require:
      - pkg: consul_prequsistes_package

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

setup_consul_sh:
  file.managed:
    - name: /etc/systemd/consul/consul_start.sh
    - source: salt://consul-agent/files/consul_start.sh
    - makedirs: True
    - mode: 0755

setup_consul_json:
  file.managed:
    - name: /etc/systemd/consul/common.json
    - source: salt://consul-agent/files/common.json
    - makedirs: True

consul.service:
  service.running:
    - enable: True

consul-template-agent.service:
  service.running:
    - enable: True
    
{% endif %}