#!/bin/bash
set -ex

for i in `seq 1 10`;
do
    apt-get update && break || sleep 15
done

apt-get install -y tox \
    build-essential \
    git-core \
    libssl-dev \
    libffi-dev \
    python2.7 \
    python-dev \
    python-ndg-httpsclient \
    gzip \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    ;

cd /opt/openstack-ansible
export BOOTSTRAP_OPTS="bootstrap_host_ubuntu_repo=http://mirror.rackspace.com/ubuntu"
export ANSIBLE_ROLE_FETCH_MODE=git-clone
bash scripts/bootstrap-ansible.sh

cd /opt/openstack-ansible-os_keystone
tox -e upgrade
