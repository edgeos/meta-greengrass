IMAGE_INSTALL_append = " \
  greengrass \
  "

IMAGE_BUFF_SIZE_append = " + 53248"
# IMAGE_BUFF_SIZE += 53248

LAMBDA_DIR := "${IMAGE_ROOTFS}/greengrass/ggc/packages/1.3.0/lambda"

BIN_KEEP += " \
  ${LAMBDA_DIR}/arn/aws/lambda/arn:aws:lambda:::function:GGConnManager/connmanager \
  ${LAMBDA_DIR}/arn/aws/lambda/arn:aws:lambda:::function:GGIPDetector:1/ipdetector \
  ${LAMBDA_DIR}/arn/aws/lambda/arn:aws:lambda:::function:GGShadowService/spectre \
  ${LAMBDA_DIR}/arn/aws/lambda/arn:aws:lambda:::function:GGTES/tes \
  ${LAMBDA_DIR}/arn/aws/lambda/arn:aws:lambda:::function:GGDeviceCertificateManager/certmanager \
  ${LAMBDA_DIR}/arn/aws/lambda/arn:aws:lambda:::function:GGRouter/router \
  ${LAMBDA_DIR}/arn/aws/lambda/arn:aws:lambda:::function:GGShadowSyncManager/syncmanager \
"