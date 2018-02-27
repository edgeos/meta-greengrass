FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://greengrass.cfg"
do_configure_append() {
        #this is run from
        #./tmp/work/imx6qsabresd-poky-linux-gnueabi/linux-imx/3.10.53-r0/git
        cat ../*.cfg >> ${B}/.config
}
