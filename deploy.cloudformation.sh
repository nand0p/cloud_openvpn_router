#!/bin/bash

keyName=cloud-openvpn-router
stackName="$keyName-$(date +%Y%m%d-%H%M)"
cfnFile="file://cloudformation.json"

clear
echo $0

if [ -z "$OVPN_CIDR" ] || 
    [ -z "$OVPN_SSH_IP" ] ||
    [ -z "$OVPN_PORT" ]
then
    echo
    echo "Environment variables must be set: "
    echo 
    echo "OVPN_CIDR: $OVPN_CIDR"
    echo "OVPN_PORT: $OVPN_PORT"
    echo "OVPN_SSH_IP: $OVPN_SSH_IP"
    echo
    exit
fi

echo "OVPN_CIDR: $OVPN_CIDR"
echo "OVPN_PORT: $OVPN_PORT"
echo "OVPN_SSH_IP: $OVPN_SSH_IP"

if [ "$AWS_PROFILE" ]
then
    AWS_PROFILE=" --profile $AWS_PROFILE "
    echo "Setting awscli profile: $AWS_PROFILE"
fi

echo
echo "$stackName :: $cfnFile"
echo
echo
echo "==> create $keyName key-pair:"
aws $AWS_PROFILE ec2 delete-key-pair --key-name $keyName
privateKeyValue=$(aws $AWS_PROFILE ec2 create-key-pair --key-name $keyName --query 'KeyMaterial' --output text)
echo
echo
echo "==> load variables:"
echo
echo
cfnParameters=" ParameterKey=KeyName,ParameterValue=$keyName "
cfnParameters+=" ParameterKey=OvpnCidr,ParameterValue=$OVPN_CIDR "
cfnParameters+=" ParameterKey=OvpnPort,ParameterValue=$OVPN_PORT "
cfnParameters+=" ParameterKey=OvpnSshIP,ParameterValue=$OVPN_SSH_IP "
echo $cfnParameters
echo
echo "==> launch openvpn stack:"
echo
echo
aws $AWS_PROFILE cloudformation create-stack --stack-name $stackName --disable-rollback --template-body $cfnFile --parameters "ParameterKey=PrivateKey,ParameterValue=$privateKeyValue" $cfnParameters
echo
echo
echo "==> wait for stack:"
sleep 5
echo
echo
echo "==> Write out private key $keyName.pem:"
echo
echo
rm -fv $keyName.pem
aws $AWS_PROFILE cloudformation describe-stacks --stack-name $stackName|grep PrivateKey -A22|cut -f3 > $keyName.pem
chmod -c 0400 $keyName.pem
echo
echo
