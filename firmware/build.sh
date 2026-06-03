#!/bin/bash

IMAGE="sampler_keyboard-qmk:latest"

if ! docker image inspect "${IMAGE}" > /dev/null 2>&1; then
    echo "Image ${IMAGE} not found. Building ${IMAGE}..."
    docker build -t "${IMAGE}" .
else
    echo "Image ${IMAGE} already exists. Skipping docker build."
fi

KEYBOARD="sampler_keyboard"

case "${1:-default}" in
    default)
	echo "Building a firmware with default keymap..."
	KEYMAP="default"
	;;
    via)
	echo "Building a firmware for VIA..."
	KEYMAP="via"
	;;
    *)
	echo "Invalid keymap: $2"
	echo "Falling back to build a firmware with default keymap..."
	KEYMAP="default"
	;;
esac

docker run --rm -it \
    -v ./src:/qmk_firmware/keyboards/$KEYBOARD \
    -v ./output:/qmk_firmware/.build \
    $IMAGE \
    /bin/bash \
    -c "
	qmk compile -kb $KEYBOARD -km $KEYMAP &&
	chown -R $(id -u):$(id -g) .build/
    "

