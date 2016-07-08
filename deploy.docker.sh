#!/bin/bash

# build the container
docker build -t nand0p/cloud_openvpn_router .

# run the container
docker run --privileged -p 443:443 -d nand0p/cloud_openvpn_router

