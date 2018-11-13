import sys
import json
import base64
import os

result = sys.stdin.read()
element = json.loads(result)
payload = element[-1]["Payload"]
payload = base64.b64decode(payload).decode('utf-8')
hostnames = payload.split(',')


# with open("/var/log/test.log", "w") as file:
#     file.write(str(hostnames))
#     file.write(check_name)

for h in hostnames:
    os.popen("salt-call publish.publish '{}' agent.create {}".format(h, 'sensu/agent/' + h + '/subs'))

