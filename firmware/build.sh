#!/bin/bash

set -euo pipefail

FIRMWARE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="sampler_keyboard-qmk:latest"
KEYBOARD="sampler_keyboard"

case "${1:-default}" in
    default)
        KEYMAP="default"
        ;;
    via)
        KEYMAP="via"
        ;;
    *)
        echo "Invalid keymap: $1. Usage: $0 [default|via]" >&2
        exit 1
        ;;
esac

if [[ -z "${CONTAINER_ENGINE:-}" ]]; then
    if command -v docker > /dev/null 2>&1; then
        CONTAINER_ENGINE="docker"
    else
        CONTAINER_ENGINE="podman"
    fi
fi

if ! command -v "$CONTAINER_ENGINE" > /dev/null 2>&1; then
    echo "Docker or Podman is required to build the firmware." >&2
    exit 1
fi

ENGINE=("$CONTAINER_ENGINE")
BUILD_OPTIONS=()
RUN_OPTIONS=()
OUTPUT_OWNER="$(id -u):$(id -g)"

case "$CONTAINER_ENGINE" in
    podman)
        # Keep this build's storage separate from the user's other containers.
        # VFS + ignore_chown_errors also works without /etc/subuid or /etc/subgid.
        if [[ -z "${PODMAN_STORAGE_DIR:-}" ]]; then
            case "$(stat -f -c %T "$HOME")" in
                nfs|nfs4)
                    # Rootless container storage cannot be used on NFS.
                    PODMAN_STORAGE_DIR="/tmp/sampler_keyboard-podman-$(id -u)"
                    ;;
                *)
                    PODMAN_STORAGE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sampler_keyboard/podman"
                    ;;
            esac
        fi
        mkdir -p -m 700 "$PODMAN_STORAGE_DIR"
        if [[ -L "$PODMAN_STORAGE_DIR" ]] ||
           [[ -e "$PODMAN_STORAGE_DIR" && ! -O "$PODMAN_STORAGE_DIR" ]]; then
            echo "Podman storage must be a directory owned by the current user: $PODMAN_STORAGE_DIR" >&2
            exit 1
        fi
        chmod 700 "$PODMAN_STORAGE_DIR"
        PODMAN_STORAGE_DIR="$(cd -- "$PODMAN_STORAGE_DIR" && pwd)"
        export TMPDIR="$PODMAN_STORAGE_DIR/tmp"
        mkdir -p "$TMPDIR"
        ENGINE+=(--root "$PODMAN_STORAGE_DIR/storage"
                 --runroot "$PODMAN_STORAGE_DIR/run"
                 --storage-driver vfs --storage-opt vfs.ignore_chown_errors=true)
        # NFS cannot be relabeled; the host network avoids rootless network helpers.
        BUILD_OPTIONS+=(--layers=false --network host --security-opt label=disable)
        RUN_OPTIONS+=(--user 0:0 --network none --cgroups disabled --security-opt label=disable)
        # Container root maps to the invoking user in rootless Podman.
        OUTPUT_OWNER="0:0"
        ;;
    docker)
        ;;
    *)
        echo "Unsupported container engine: $CONTAINER_ENGINE (use docker or podman)." >&2
        exit 1
        ;;
esac

mkdir -p "$FIRMWARE_DIR/output"

if ! "${ENGINE[@]}" image inspect "$IMAGE" > /dev/null 2>&1; then
    echo "Image $IMAGE not found. Building with $CONTAINER_ENGINE..."
    "${ENGINE[@]}" build "${BUILD_OPTIONS[@]}" -t "$IMAGE" "$FIRMWARE_DIR"
else
    echo "Image $IMAGE already exists. Skipping image build."
fi

echo "Building firmware with $KEYMAP keymap..."
"${ENGINE[@]}" run --rm "${RUN_OPTIONS[@]}" \
    -v "$FIRMWARE_DIR/src:/qmk_firmware/keyboards/$KEYBOARD:ro" \
    -v "$FIRMWARE_DIR/output:/qmk_firmware/.build" \
    "$IMAGE" \
    /bin/bash -e -c '
        qmk compile -kb "$1" -km "$2"
        chown -R "$3" .build/
    ' -- "$KEYBOARD" "$KEYMAP" "$OUTPUT_OWNER"

echo "Firmware written to $FIRMWARE_DIR/output/${KEYBOARD}_${KEYMAP}.uf2"
