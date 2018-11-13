consul_prequsistes_package:
  pkg.installed:
    - pkgs:
      - unzip
      - python-m2crypto

install_python-server:
  pip.installed:
    - name: python-consul
    - reload_modules: True
    - trusted_host: pypi.python.org
    - require:
      - pkg: master_python_pip
  
master_python_pip:
  pkg.installed:
    - name: python-pip