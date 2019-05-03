IMAGE_INSTALL_append = " \
  greengrass \
  "

# Make sure greengrass binaries are not removed by shrinkwrap
GG_BINS := "$(find ${IMAGE_ROOTFS}/greengrass -type f -executable | sed 's|:|\\:|g' | tr "\n" " ")"
BIN_KEEP += " ${GG_BINS} "
