SUMMARY = "This recipe installs greengrass in the root directory"
SECTION = "Install GGC"
LICENSE = "CLOSED"
#LIC_FILES_CHKSUM = ""

# add greengrass directory to the build
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#Avoid some checks while installing GG packages
INSANE_SKIP_${PN} = "already-stripped"
INSANE_SKIP_${PN} = "ldflags"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

#SRC_URI = "file://${BP}.tar.gz"
SRC_URI = "file://${PN}-${BUILD_OS}-${TARGET_ARCH}-${PV}.tar.gz"

#inherit autotools
inherit bin_package


# DEPENDENCIES
RDEPENDS_${PN} = "sqlite3 openssh bash ca-certificates openssl python-modules"

