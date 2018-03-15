IMAGE_INSTALL_append = " \
  greengrass \
  "

# Keep image buff size in 4096 block increments
IMAGE_ROOTFS_EXTRA_SPACE_append = " + 65000"
IMAGE_BUFF_SIZE_append = " + 65000 + 150000"

GG_BINS := "$(find ${IMAGE_ROOTFS}/greengrass -type f -executable | sed 's|:|\\:|g' | tr "\n" " ")"
BIN_KEEP += " ${GG_BINS} "
