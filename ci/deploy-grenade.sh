#!/bin/bash
set -ex

SSH_PUBLIC_KEY=$1
SSH_PRIVATE_KEY_BODY=$2
GRENADE_BRANCH=$3
RACK_USERNAME=$4
RACK_API_KEY=$5
RACK_REGION=$6
IMAGE_NAME=$7

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INSTANCE_NAME="ci-grenade-`shuf -i 100000-999999 -n 1`"

source $DIR/common-functions.sh

bootstrap
bootstrap_ssh "$SSH_PUBLIC_KEY" "$SSH_PRIVATE_KEY_BODY"
bootstrap_rack "$RACK_USERNAME" "$RACK_API_KEY" "$RACK_REGION"
trap "delete_instance \"$INSTANCE_NAME\"" EXIT
provision_instance "$INSTANCE_NAME" "$IMAGE_NAME"

public_ip=$(get_public_ip $INSTANCE_NAME)

echo "Running grenade @ $public_ip..."
ssh \
    -o BatchMode=yes \
    root@$public_ip 'bash -s' < $DIR/../install-grenade.sh "$GRENADE_BRANCH"
