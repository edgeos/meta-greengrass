FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#TODO figure out how to dynamically determine the version greengrass and rename greengrass-ggc-packages-<greengrass version>-ggc_root.mount
SRC_URI_append = " \
    file://greengrass-ggc-var.mount \
    file://greengrass-ggc-packages.mount \
    file://greengrass-ggc-deployment.mount \
    file://greengrass-certs.mount \
    file://greengrass.public.key \
    file://greengrass.cert.pem \
    file://greengrass.private.key \
    file://greengrass-root-ca-cert.pem \
    "

SYSTEMD_SERVICE_${PN}_append = " \
    greengrass-certs.mount \
    greengrass-ggc-deployment.mount \
    greengrass-ggc-packages.mount \
    greengrass-ggc-var.mount \
    "

do_install_append () {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then

        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 \
            ${WORKDIR}/greengrass-ggc-var.mount \
            ${WORKDIR}/greengrass-ggc-packages.mount \
            ${WORKDIR}/greengrass-ggc-deployment.mount \
            ${WORKDIR}/greengrass-certs.mount \
            ${D}${systemd_unitdir}/system
        
        #Update mount scripts to use actual parition names
        sed -i -e 's,@EDGEOS_BOOT_FS_LABEL@,${EDGEOS_BOOT_FS_LABEL},g' \
               -e 's,@EDGEOS_ROOT_FS_LABEL@,${EDGEOS_ROOT_FS_LABEL},g' \
               -e 's,@EDGEOS_UPDATE_FS_LABEL@,${EDGEOS_UPDATE_FS_LABEL},g' \
               -e 's,@EDGEOS_CONFIG_FS_LABEL@,${EDGEOS_CONFIG_FS_LABEL},g' \
               -e 's,@EDGEOS_DATA_FS_LABEL@,${EDGEOS_DATA_FS_LABEL},g' \
               ${D}${systemd_unitdir}/system/*.mount

        # Yocto gets confused if we use strange file names - so we rename it here
        # https://bugzilla.yoctoproject.org/show_bug.cgi?id=8161
        CONFUSED=" \
            "

        for f in $CONFUSED; do
            STRANGE=`echo $f | sed 's/x2d/\\\\x2d/g'`
            install -c -m 0644 ${WORKDIR}/${f} ${D}${systemd_unitdir}/system/${STRANGE}
            ln -sf ${systemd_unitdir}/system/${STRANGE} ${D}${sysconfdir}/systemd/system/edgeos-bind.target.wants
        done
    fi
}
