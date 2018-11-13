install_python-consul:
  pip.installed:
    - name: python-consul
    - reload_modules: True
    - trusted_host: pypi.python.org
    - require:
      - pkg: master_python_pip

master_python_pip:
  pkg.installed:
    - name: python-pip