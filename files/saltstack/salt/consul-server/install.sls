{% set CONSUL_VERSION = "1.4.0" %}

consul_binary_download:
  cmd.run:
    - name: wget -O /tmp/consul.zip https://releases.hashicorp.com/consul/{{ CONSUL_VERSION }}/consul_{{ CONSUL_VERSION }}_linux_amd64.zip && unzip -o /tmp/consul.zip -d /usr/local/bin
    - unless:
      - "consul version | grep {{ CONSUL_VERSION }}"
      - "test -f /usr/local/bin/consul"
    - require:
      - pkg: consul_prequsistes_package

install_consul_service:
  file.managed:
    - name: /etc/systemd/system/consul.service
    - source: salt://consul-server/files/consul.service

install_consul_watch_check:
  file.managed:
    - name: /etc/systemd/system/watch_check.service
    - source: salt://consul-server/files/watch_check.service

install_consul_watch_agent:
  file.managed:
    - name: /etc/systemd/system/watch_agent.service
    - source: salt://consul-server/files/watch_agent.service
  
install_consul_config:
  file.managed:
    - name: /tmp/config.json
    - source: salt://consul-server/files/config.json
  
setup_consul_server_sh:
  file.managed:
    - name: /etc/systemd/consul/consul_server_start.sh 
    - source: salt://consul-server/files/consul_server_start.sh
    - makedirs: True
    - mode: 0755

install_consul_agent_cmd:
  file.managed:
    - name: /tmp/agent.py
    - source: salt://consul-server/files/agent.py
    - mode: 755

consul:
  service.running:
    - enable: True

watch_check:
  service.running:
    - enable: True

watch_agent:
  service.running:
    - enable: True

