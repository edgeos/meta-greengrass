IMAGE_INSTALL_append = " \
  greengrass \
  "

IMAGE_BUFF_SIZE_append = " + 53248"
# IMAGE_BUFF_SIZE += 53248

GG_BINS := "$(find ${IMAGE_ROOTFS}/greengrass -type f -executable | sed 's|:|\\:|g' | tr "\n" " ")"
BIN_KEEP += " ${GG_BINS} "
