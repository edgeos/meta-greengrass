IMAGE_INSTALL_append = " \
  greengrass \
  "

IMAGE_BUFF_SIZE_append = " + 53248"
# IMAGE_BUFF_SIZE += 53248

# LAMBDA_DIR := "${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda"
# GG_BINS := "$(find ${IMAGE_ROOTFS}/greengrass -type f -executable | tr "\n" " " | )"


GG_BINS := "$(find ${IMAGE_ROOTFS}/greengrass -type f -executable | sed 's|:|\\:|g' | tr "\n" " ")"
BIN_KEEP += " ${GG_BINS} "

# BIN_KEEP += " \
#   ${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda/arn\:aws\:lambda\:\:\:function\:GGConnManager/connmanager \
#   ${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda/arn\:aws\:lambda\:\:\:function\:GGDeviceCertificateManager/certmanager \
#   ${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda/arn\:aws\:lambda\:\:\:function\:GGIPDetector\:1/ipdetector \
#   ${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda/arn\:aws\:lambda\:\:\:function\:GGRouter/router \
#   ${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda/arn\:aws\:lambda\:\:\:function\:GGShadowService/spectre \
#   ${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda/arn\:aws\:lambda\:\:\:function\:GGShadowSyncManager/syncmanager \
#   ${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda/arn\:aws\:lambda\:\:\:function\:GGTES/tes \
#   ${IMAGE_ROOTFS}/greengrass/ota/ota_agent_v1.0.0/ggc-ota \
# "