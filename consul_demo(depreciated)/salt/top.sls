base:
  'consul-server*':
    - consul-server
    - sensu-agent
  'master':
    - consul-agent
  'jump*':
    - consul-agent

