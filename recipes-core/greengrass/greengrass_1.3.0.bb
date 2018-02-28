SUMMARY = "This recipe installs greengrass in the root directory"
SECTION = "Install GGC"
LICENSE = "CLOSED"
#LIC_FILES_CHKSUM = ""

inherit bin_package useradd systemd

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# Avoid some checks while installing GG packages
INSANE_SKIP_${PN} = "already-stripped"
INSANE_SKIP_${PN} = "ldflags"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

SRC_URI = " \
	file://${PN}-${BUILD_OS}-${TARGET_ARCH}-${PV}.tar.gz \
	file://greengrassd.service \
	file://config.json \
	file://edf42b1529.public.key \
	file://edf42b1529.cert.pem \
	file://edf42b1529.private.key \
	file://root-ca-cert.pem \
	"

SYSTEMD_SERVICE_${PN} = " \
    ${PN}d.service \
    "

S = "${WORKDIR}/${BPN}"

# These tasks don't need to be run in this recipe, so they're disabled
# here.
do_configure[noexec] = "1"
do_compile[noexec] = "1"

# Perform the installation of the AWS Greengrass binaries, which consists
# of copying the unpacked files into the /greengrass folder
# ${D} = /
# ${BPN} = greengrass
do_install() {
	install -d ${D}/${BPN}
	tar --no-same-owner --exclude='./patches' --exclude='./.pc' -cpf - -C ${S} . \
| tar --no-same-owner -xpf - -C ${D}/${BPN}

	# Install systemd init scripts for greengrass
	install -d ${D}${systemd_unitdir}/system
	install -c -m 0644 ${WORKDIR}/${PN}d.service ${D}${systemd_unitdir}/system

	# Create greengrass r/w directories for data and logs in /mnt/data and bind mount
	install -d ${D}/${BPN}/ggc/packages/${PV}/ggc_root
	install -d ${D}/${BPN}/ggc/var/log

	# Copy in configuration file
	install -c -m 0644 ${WORKDIR}/config.json ${D}/{BPN}/config

	# TEMPORARY: Copy in certs
	install -c -m 0644 ${WORKDIR}/edf42b1529.cert.pem ${D}/{BPN}/certs
	install -c -m 0644 ${WORKDIR}/edf42b1529.private.key ${D}/{BPN}/certs
	install -c -m 0644 ${WORKDIR}/edf42b1529.public.key ${D}/{BPN}/certs
	install -c -m 0644 ${WORKDIR}/root-ca-cert.pem ${D}/{BPN}/certs
	
}

# Perform post installation tasks that are required for AWS Greengrass to
# run. These include:
# 1. Enabling protection for hardlinks and symlinks
# 2. Adding cgroup support in `/etc/fstab`
pkg_postinst_${PN}() {

	# Enable protection for hardlinks and symlinks
	if ! grep -qs 'protected_.*links' $D${sysconfdir}/sysctl.conf; then
		cat >> $D${sysconfdir}/sysctl.conf <<- EOF
			# AWS Greengrass: protect hardlinks/symlinks
			fs.protected_hardlinks = 1
			fs.protected_symlinks = 1
		EOF
	fi

	if [ -f "$D${sysconfdir}/fstab" ]; then

		if ! grep -qs '^cgroup' $D${sysconfdir}/fstab; then
			cat >> $D${sysconfdir}/fstab <<- EOF
				# Greengrass: mount cgroups
				cgroup    /sys/fs/cgroup    cgroup    defaults    0  0
			EOF
		fi
	fi

}

USERADD_PACKAGES = "${PN}"

# The ggc_group group and ggc_user are required by AWS Greengrass.
GROUPADD_PARAM_${PN} = "-r ggc_group"
USERADD_PARAM_${PN} = "-r -M -N -g ggc_group -s /bin/false ggc_user"

# DEPENDENCIES
RDEPENDS_${PN} = " \
	sqlite3 \
	openssl \
	bash \
	ca-certificates \
	openssl \
	python-argparse \
	python-json \
	python-numbers \
	"
