import os


def create(key):
  ''' 
  Create hcl template for sensu agent.yml

  CLI Example:

  .. code-block:: bash

    salt <target> agent.create <key>

  target should be the minionid
  key is consul KV path

  '''
  hclpath = __salt__['grains.filter_by']({'Windows': 'C:/consul/conf/agent.hcl', 'Debian': '/etc/sensu/agent.hcl'})
  ctmplpath = __salt__['grains.filter_by']({'Windows': 'C:/consul/conf/agent.ctmpl', 'Debian': '/etc/sensu/agent.ctmpl'})
  ymlpath = __salt__['grains.filter_by']({'Windows': 'C:/consul/conf/agent.yml', 'Debian': '/etc/sensu/agent.yml'})


  tmplout = '{{key "'+ key + '"}}'
  with open(hclpath, "w") as agenthcl, open(ctmplpath, "w") as agenttmpl:
    agenthcl.write("""template {
    source = """ + '"{}"'.format(hclpath) + """
    destination = """ + '"{}"'.format(ymlpath) + """
    command = "salt-call service.restart sensu-agent" """ + """\n}"""
  ) 
    agent_config = ['backend-url: \n', '  - "ws://172.20.20.32:8081"\n', 'subscriptions: "' + tmplout + '"']
    agenttmpl.writelines(agent_config)

  os.popen('salt-call service.restart consul-template-agent')