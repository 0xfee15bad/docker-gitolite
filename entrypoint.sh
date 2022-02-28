#!/bin/sh

GITOLITE_USER=git
SSH_KEY_LINK=$(find /etc/ssh -type l -name '*_key')
SSH_KEY_TYPE=$(echo "$SSH_KEY_LINK" | sed 's/.*_\([a-z0-9]*\)_key/\1/g')
SSH_KEY_PATH=$(readlink "$SSH_KEY_LINK")
SECRETS_PATH=/run/secrets
ADMIN_KEY_NAME=admin_key # as setup in the docker-compose/CLI

if [ ! -f "$SSH_KEY_PATH" ]
then
    mkdir -p "$(dirname "$SSH_KEY_PATH")"
    ssh-keygen -N '' -t "$SSH_KEY_TYPE" -f "$SSH_KEY_PATH"
fi

VOLUME_USER=$(eval stat -c '%U' ~$GITOLITE_USER)
VOLUME_GROUP=$(eval stat -c '%G' ~$GITOLITE_USER)
# If the home folder (root volume) has different owner/group, something must have happened
if [ "$VOLUME_USER" != "$VOLUME_GROUP" ] || [ "$VOLUME_USER" != "$GITOLITE_USER" ]
then
    printf "Fixing volume permissions... "
    eval chown -R "$GITOLITE_USER:$GITOLITE_USER" ~$GITOLITE_USER
    printf "Done!\n"
fi

ADMIN_KEY_PATH="/tmp"
# Remove any old key link
rm -f $ADMIN_KEY_PATH/*.pub
if [ -n "$GITOLITE_ADMIN_NAME" ]
then
    ADMIN_KEY_PATH="$ADMIN_KEY_PATH/$GITOLITE_ADMIN_NAME.pub"
else
    ADMIN_KEY_PATH="$ADMIN_KEY_PATH/Admin.pub"
fi
ln -s "$SECRETS_PATH/$ADMIN_KEY_NAME" "$ADMIN_KEY_PATH"

su "$GITOLITE_USER" -c "gitolite setup -pk $ADMIN_KEY_PATH"

su "$GITOLITE_USER" -c "/usr/sbin/sshd -D"
