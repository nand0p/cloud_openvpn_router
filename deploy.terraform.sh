#!/bin/bash

TF_VAR_stack_name="cloud-openvpn-router-$(date +%m%d-%H%M)"

clear
echo $0

if [ -z "$TF_VAR_access_key" ] || 
    [ -z "$TF_VAR_secret_key" ] ||
    [ -z "$TF_VAR_trusted_ip" ]
then
    echo
    echo "Environment variables must be set: "
    echo 
    echo "TF_VAR_access_key: $TF_VAR_access_key"
    echo "TF_VAR_secret_key: $TF_VAR_secret_key"
    echo "TF_VAR_trusted_ip: $TF_VAR_trusted_ip"
    echo
    exit
fi

echo "TF_VAR_access_key: $TF_VAR_access_key"
echo "TF_VAR_secret_key: $TF_VAR_secret_key"
echo "TF_VAR_trusted_ip: $TF_VAR_trusted_ip"
echo "TF_VAR_stack_name: $TF_VAR_stack_name"

export TF_VAR_access_key
export TF_VAR_secret_key
export TF_VAR_trusted_ip
export TF_VAR_stack_name

terraform plan

sleep 2

terraform apply
