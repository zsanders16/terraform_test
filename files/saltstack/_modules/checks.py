import json

def create():
  kv = __salt__['consul.get'](key='sensu/checks', recurse=True, decode=True)  
  x = kv["data"]

  store = {}
  for k in x:
    store.update({k["Key"]:json.loads(k['Value'])})
  open("var/sensu/sensu-config/ctmplconfig.hcl", 'w').close()

  checks = {}
  for k,v in store.items():
    keyArray = k.split('/')
    key = '_'.join([keyArray[2], keyArray[3], keyArray[4]])
    value = '{{key "'+ k + '"}}'
    checks.update({key:value})

  for k,v in checks.items():
    output = {v}
    with open("/var/sensu/sensu-config/" + k + ".ctmpl", "w") as FILE:
      for i in output:
        FILE.write(i)
      # json.dump(output, FILE, ensure_ascii=False, indent=2)
    with open("var/sensu/sensu-config/ctmplconfig.hcl", "a") as myfile:
      myfile.write("""template {
        source = "/var/sensu/sensu-config/"""+k+""".ctmpl"
        destination = "/var/sensu/sensu-config/json/"""+k+""".json"
        command = "/var/sensu/sensu-config/json/sensu_checks -json-file /var/sensu/sensu-config/json/"""+k+""".json -config-file /etc/sensu/sensu-config/files/config"}\n"""
      )