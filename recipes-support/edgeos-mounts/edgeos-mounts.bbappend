FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#TODO figure out how to dynamically determine the version greengrass and rename greengrass-ggc-packages-<greengrass version>-ggc_root.mount
SRC_URI_append = " \
    file://greengrass-ggc-packages-1.3.0-ggc_root.mount \
    file://greengrass-ggc-var-log.mount \
    file://greengrass-ggc-packages-1.3.0-var.mount \
    file://greengrass-ggc-deployment-lambda.mount \
    file://greengrass-certs.mount \
    file://greengrass.public.key \
    file://greengrass.cert.pem \
    file://greengrass.private.key \
    file://greengrass-root-ca-cert.pem \
    "

SYSTEMD_SERVICE_${PN}_append = " \
    "

do_install_append () {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then

        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 \
            ${WORKDIR}/greengrass-ggc-packages-1.3.0-ggc_root.mount \
            ${WORKDIR}/greengrass-ggc-var-log.mount \
            ${WORKDIR}/greengrass-ggc-packages-1.3.0-var.mount \
            ${WORKDIR}/greengrass-ggc-deployment-lambda.mount \
            ${WORKDIR}/greengrass-certs.mount \
            ${D}${systemd_unitdir}/system
            
            # TEMPORARY: Copy in certs
        install -c -m 0644 ${WORKDIR}/greengrass.cert.pem ${D}/${BPN}/certs
        install -c -m 0400 ${WORKDIR}/greengrass.private.key ${D}/${BPN}/certs
        install -c -m 0644 ${WORKDIR}/greengrass.public.key ${D}/${BPN}/certs
        install -c -m 0400 ${WORKDIR}/greengrass-root-ca-cert.pem ${D}/${BPN}/certs
        
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
