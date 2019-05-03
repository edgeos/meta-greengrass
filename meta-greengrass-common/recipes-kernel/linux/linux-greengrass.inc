FILESEXTRAPATHS_prepend := "${THISDIR}/linux-greengrass:"

SRC_URI_append = " \
                  file://greengrass.cfg \
                 "

ARM_KEEP_OABI_arm = "0"
