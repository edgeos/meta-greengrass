Kernel features customization (MQUEUE, CGROUPS, etc) – Done
The recipe only applies to the imx-linux kernel because to customize the kernel configuration you need to provide a linux name. Extending it to new kernels is straightforward. Check (meta-greengrass/recipes-kernel/linux/linux-imx_4.9.11.bbappend)

Includes the following needed packages (done)
Sqlite3, openssh, bash, ca-certificates, openssl, python-modules, python

Install greengrass 1.3.0 into the rootfs (done)

The following variables should be defined (they are set by bitbake):
PN, BUILD_OS, TARGET_ARCH, PV

The following activities still need to be done:
- Include hard/softlink protection into /etc/sysctl.d
- Include all dependencies for OTA
- Include Node.js (Optional)
- Include Java 8 (Optional)
- Create directory /var/run
- Enable /dev/stdin , /dev/stdout , /dev/stderr
- Add ggc user and group

We should decide what runtimes to support...  

Technical debt
- Needs to separate kernel specific customization from standard ones. Currently imx-linux overrites some built in yocto features to detect Kernel Customization
- Needs to provide a licence with the distribution, right now there is no license being shipped with the recipe
- Create a public visible git with the recipe, so manufacturers can use and evolve it freely

Currently the recipe only have ARM support but adding other arch should be straight forward, it only requires repackaging the current tar.gz of the arch.
