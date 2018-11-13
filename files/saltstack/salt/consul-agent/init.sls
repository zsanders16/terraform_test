{% if salt['grains.get']('os') == 'Windows' %}
include:
  - consul-agent.install
  - consul-agent.template
{% endif %}

{% if salt['grains.get']('os') == 'Ubuntu' %}

include:
  - consul-agent.packages
  - consul-agent.install
  - consul-agent.template
{% endif %}