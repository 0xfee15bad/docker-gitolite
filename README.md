# Gitolite Docker Image

[Alpine](https://alpinelinux.org)-based [Gitolite](https://gitolite.com) image

## Example configuration

```yaml
version: "2.1"
services:
  gitolite:
    image: ghcr.io/0xfee15bad/docker-gitolite:master
    container_name: gitolite
    volumes:
      - /mnt/git:/var/lib/git
    environment:
      - TZ=Europe/London
      - GITOLITE_ADMIN_NAME=JohnDoe
    restart: unless-stopped
    ports:
      - "220:22"
    secrets:
     - admin_key

secrets:
  admin_key:
    file: ~/.ssh/id_ed25519.pub
```
