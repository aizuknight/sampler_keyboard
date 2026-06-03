FROM qmkfm/qmk_cli:1.2.0

ENV QMK_FIRMWARE_VERSION=0.31.11

RUN git clone \
  -b ${QMK_FIRMWARE_VERSION} \
  --depth 1 \
  --recurse-submodules \
  https://github.com/qmk/qmk_firmware.git \
  /qmk_firmware

WORKDIR /qmk_firmware
