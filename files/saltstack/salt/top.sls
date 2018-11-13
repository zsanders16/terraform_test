base:
  'consul-server*':
    - consul-server
    - sensu-agent
  'web*':
    - consul-agent
    - sensu-agent
  'sensu-backend':
    - sensu-backend
    - consul-agent
  'master':
    - consul-agent
    - sensu-agent
  'winminion1':
    - consul-agent
    - sensu-agent
