FROM alpine:latest

RUN apk add gitolite \
            openssh-server \
            tzdata

COPY entrypoint.sh /usr/local/bin/

# Unlock the account and generate a password (safe since we'll disable password auth later)
## Generate a pseudo-random 128 byte-long data
## Filter out everything that is not an alphanumerical character
## Take the first 16 characters of it
RUN yes "$(head -c 128 /dev/urandom | tr -dc '0-9a-zA-Z' | head -c 16)" | passwd git

# Change some ssh configurations
ARG ssh_dir=/etc/ssh
ARG ssh_conf=$ssh_dir/sshd_config
ARG ssh_key_type=ed25519
ARG ssh_host_key=ssh_host_${ssh_key_type}_key
## Uncomment host key
RUN sed "s/#\(HostKey .*$ssh_host_key\)/\1/" -i $ssh_conf
## Enable public key auth
RUN sed 's/.*\(PubkeyAuthentication\) .*/\1 yes/' -i $ssh_conf
## Disable password auth
RUN sed 's/.*\(PasswordAuthentication\) .*/\1 no/' -i $ssh_conf
## Disable all subsystems
RUN sed 's/^\(Subsystem.*\)/#\1/' -i $ssh_conf

# Link the system SSH key to the one of the git user, for persistency
RUN ln -s ~git/.ssh/$ssh_host_key $ssh_dir

ENTRYPOINT [ "entrypoint.sh" ]
