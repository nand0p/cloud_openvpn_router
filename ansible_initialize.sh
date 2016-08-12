#!/bin/bash

sudo yum -y install libffi-devel \
                    gcc \
                    openssl-devel \
                    libyaml-devel \
                    python-devel \
                    autoconf \
                    automake \
                    libtool \
                    lzo-devel \
                    python27-lzo \
                    pam-devel

if [ ! -d "ansible_venv" ]; then
  virtualenv ansible_venv
fi

source ansible_venv/bin/activate

pip install -U pip
pip install -U ansible

ansible-playbook ansible_configure.yml -vvv -e timestamp=$(date +%s)
