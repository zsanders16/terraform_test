sensu-backend-repository:
  cmd.run:
    - name: curl -s https://packagecloud.io/install/repositories/sensu/beta/script.deb.sh | sudo bash

install-sensu-backend:
  pkg.installed:
    - pkgs:
      - sensu-backend

/var/sensu/sensu-config/checks:
  file.directory:
    - makedirs: True

sensu-backend-config:
  file.managed:
    - name: /etc/sensu/backend.yml
    - source: salt://sensu-backend/files/backend.yml

sensu-consul-auth:
  file.managed:
    - name: /var/sensu/sensu-config/config
    - source: salt://sensu-backend/files/config

check-scripts:
  file.managed:
    - name: /var/sensu/sensu-config/json/sensu_checks
    - source: salt://sensu-backend/files/sensu_checks
    - makedirs: True
    - mode: 744

check-scripts-config:
  file.managed:
    - name: /etc/sensu/sensu-config/files/config
    - source: salt://sensu-backend/files/config
    - makedirs: True

sensu-backend:
  service.running:
    - enable: True

setup_consul-template_serviced:
  file.managed:
    - name: /etc/systemd/system/consul-template.service
    - source: salt://sensu-backend/files/consul-template.service

consul-template.service:
  service.running:
    - enable: True