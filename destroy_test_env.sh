#!/bin/bash

cd projects/core_infrastructure
admin_subnet_id=$(terraform output -json admin_subnet_id | jq .value)
consul_subnet_id=$(terraform output -json consul_subnet_id | jq .value)
echo $admin_subnet_id

cd ../../packer/images
image_id=$(cat manifest.json | jq .builds[0].artifact_id)

cd ../../projects/monitor_env
terraform destroy -auto-approve -var "image_id=$image_id" -var "admin_subnet_id=$admin_subnet_id" -var "consul_subnet_id=$consul_subnet_id"

cd ../core_infrastructure
terraform destroy -auto-approve

cd ../../packer/images
rm -f manifest.json