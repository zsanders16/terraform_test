base:
  'consul-server*':
    - consul-server
    - sensu-agent
  'jumpbox':
    - consul-agent
  'master':
    - consul-agent

