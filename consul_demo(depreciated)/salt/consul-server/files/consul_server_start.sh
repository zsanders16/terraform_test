#!/usr/bin/env bash

ip=$(ifconfig eth1 | grep 'inet addr' | awk '{ print substr($2,6) }')
consul agent -bind $ip -config-file /tmp/config.json