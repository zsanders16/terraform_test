#!/bin/bash

cd ./projects/core_infrastructure
terraform init && terraform apply -auto-approve
admin_subnet_id=$(terraform output -json admin_subnet_id | jq .value)

cd ../../packer/images
packer build salt-minion.json
image_id=$(cat manifest.json | jq .builds[0].artifact_id)

cd ../../projects/monitor_env
terraform init && terraform apply -auto-approve -var 'image_id=$image_id' -var 'admin_subnet_id=$admin_subnet_id'
