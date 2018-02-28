SUMMARY = "This recipe installs greengrass in the root directory"
SECTION = "Install GGC"
LICENSE = "CLOSED"
#LIC_FILES_CHKSUM = ""

inherit systemd

# add greengrass directory to the build
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#Avoid some checks while installing GG packages
INSANE_SKIP_${PN} = "already-stripped"
INSANE_SKIP_${PN} = "ldflags"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

#SRC_URI = "file://${BP}.tar.gz"
SRC_URI = " \
	file://${PN}-${BUILD_OS}-${TARGET_ARCH}-${PV}.tar.gz \
	file://greengrassd.service \
	"

SYSTEMD_SERVICE_${PN} = " \
    ${PN}d.service \
    "

#inherit autotools
inherit bin_package

S = "${WORKDIR}/${BPN}"


do_install() {
	install -d ${D}/${BPN}
	tar --no-same-owner --exclude='./patches' --exclude='./.pc' -cpf - -C ${S} . \
| tar --no-same-owner -xpf - -C ${D}/${BPN}

	# Install systemd init scripts for greengrass
    install -d ${D}${systemd_unitdir}/system
    install -c -m 0644 ${WORKDIR}/${PN}d.service ${D}${systemd_unitdir}/system

	# Create greengrass r/w directory in /mnt/dataand bind mount
	install -d ${D}/${BPN}/ggc/packages/${PV}/ggc_root
}

# DEPENDENCIES
RDEPENDS_${PN} = " 
	sqlite3 \
	openssl \
	bash \
	ca-certificates \
	openssl \
	python-argparse \
	python-json \
	python-numbers \
	"