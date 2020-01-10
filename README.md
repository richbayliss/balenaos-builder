Balena OS docker base image
===========================

```
$ docker build -t balenaos:build-slim .

$ docker run -it --rm --privileged \
    -v /home/richardb/Projects/balenaos-raspberrypi:/build \
    -e REPO=https://github.com/balena-os/balena-raspberrypi.git \
    -e MACHINE=raspberrypi \
    balenaos:build-slim
```
