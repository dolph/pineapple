#!/bin/bash
set -ex

SSH_PUBLIC_KEY=$1
SSH_PRIVATE_KEY_BODY=$2
RACK_USERNAME=$3
RACK_API_KEY=$4
RACK_REGION=$5
IMAGE_NAME=$6
INSTANCE_NAME=$7

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INSTANCE_NAME="ci-osa-upgrade"

source $DIR/common-functions.sh

bootstrap
bootstrap_ssh "$SSH_PUBLIC_KEY" "$SSH_PRIVATE_KEY_BODY"
bootstrap_rack "$RACK_USERNAME" "$RACK_API_KEY" "$RACK_REGION"
delete_instance "$INSTANCE_NAME"
provision_instance "$INSTANCE_NAME" "$IMAGE_NAME" "8 GB General Purpose v1"
public_ip=$(get_public_ip $INSTANCE_NAME)
upgrade_instance "$public_ip"

echo "Running OSA @ $public_ip..."

ssh \
    -o BatchMode=yes \
    root@$public_ip 'mkdir /opt/openstack-ansible/'
rsync --recursive openstack-ansible-stable/* root@$public_ip:/opt/openstack-ansible/
ssh \
    -o BatchMode=yes \
    root@$public_ip 'bash -s' < $DIR/../install-osa.sh
rsync --recursive openstack-ansible-master/* root@$public_ip:/opt/openstack-ansible/
ssh \
    -o BatchMode=yes \
    root@$public_ip 'bash -s' < $DIR/../upgrade-osa.sh
