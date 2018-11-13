{% if salt['grains.get']('os') == 'Windows' %}
{% set install_source_sensu_go_agent = 'https://artifacts.mktp.io/artifactory/sensu-assets/checks/sensu-agent.exe.tar.gz' %} 

download_sensu-go-agent:
  file.managed:
    - name: C:\\opt\\client\\sensu-agent.exe.tar.gz
    - source: {{ install_source_sensu_go_agent }}
    - source_hash: 680ac0e7bdca988c1412abf85bd820798847d1d334adbdee691573be92a4b706
    - makedirs: True

extract_sensu-go-agent:
  module.run:
  - name: archive.tar
  - tarfile: 'C:\opt\client\sensu-agent.exe.tar.gz'
  - options: '-xf'
  - dest: 'C:\\opt\\client\\'

C:\\opt\\conf\\agent.yml:
  file.managed:
    - source: salt://sensu-agent/files/agent.yml
    - makedirs: True

consul-template_install_windows_service:
  cmd.run:
    - name: 'nssm install sensu-agent C:\opt\client\sensu-agent.exe start --config-file=C:\opt\conf\agent.yml'
    - unless: 'sc query sensu-agent'

# sensu_go_agent_install_windows_service:
#   cmd.run:
#     - name: 'sc create sensu-agent start="delayed-auto" binPath= "c:\opt\client\sensu-agent.exe start --config-file=C:\opt\conf\agent.yml" DisplayName= "sensu-agent"'
#     - unless: 'sc query sensu-agent'

sensu-agent:
  service.running:
    - enable: True

{% endif %} 

{% if salt['grains.get']('os') == 'Ubuntu' %}
sensu_agent_repository:
  cmd.run:
    - name: curl -s https://packagecloud.io/install/repositories/sensu/beta/script.deb.sh | sudo bash
    - unless: 
      - 'sensu-agent version'

install-sensu-agent:
  pkg.installed:
    - pkgs:
      - sensu-agent

sensu-agent-config:
  file.managed:
    - name: /etc/sensu/agent.yml
    - source: salt://sensu-agent/files/agent.yml

sensu-agent:
  service.running:
    - enable: True

{% endif %}