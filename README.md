Cloud OpenVPN Router

This code launches an OpenVPN server in an AWS VPC.


- Cloudformation
- Ansible
- Terraform
- Docker
- Vagrant


The cloud openvpn server functions as a router between the
connecting clients. This allows remote offices, possibly with
dynamic public ip addressing, to be interconnected. 

Openvpn clients need not maintain a static IP, as they initiate
the connection to the cloud OpenVPN server. This solution allows
for remote site IP changes without issue.
