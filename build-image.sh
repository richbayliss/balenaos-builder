#!/bin/sh
if [ "$USER" != "builder" ]; then
    echo "[BUILD-IMAGE] Switching to non-root user..."
    exec sudo -E -H -u builder /build-image.sh $@
fi

REPO="${REPO:-https://github.com/balena-os/balena-raspberrypi.git}"
REPO="${1:-$REPO}"

MACHINE="${MACHINE:-raspberrypi3}"
MACHINE="${2:-$MACHINE}"

BUILD_OPTS="$3"

REPO_NAME=$(basename $REPO)
DIR=${REPO_NAME%.*}

cd /build
if [ ! -d "balena-${PLATFORM}" ]; then
    echo "[BUILD-IMAGE] Cloning repo..."
    git clone --recursive "${REPO}" .
fi
cd "${DIR}"

echo "[BUILD-IMAGE] Building for machine ${MACHINE}..."
./balena-yocto-scripts/build/barys -m "${MACHINE}" ${BUILD_OPTS}

echo "[BUILD-IMAGE] Done!"
