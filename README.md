# Meta-Greengrass Layer

Builds AWS Greengrass 1.6.0 with optional easy install into EdgeOS.

Information about AWS IoT Greengrass can be found here: [https://aws.amazon.com/greengrass/](https://aws.amazon.com/greengrass/) and [Greengrass Developer Guide](https://docs.aws.amazon.com/greengrass/latest/developerguide/what-is-gg.html).


## Steps to Build

Add meta-greengrass to current build (in EdgeOS context):

~~~bash
git submodule add -b greengrass_1.6.0 git@github.build.ge.com:leap-host/meta-greengrass.git src/layers/meta-greengrass
~~~

Add meta-greengrass layers to bblayers.conf (in EdgeOS context):

~~~
# Example from yocto-qemu
cat src/layers/meta-edgeos-qemu/conf/samples/bblayers.conf.sample 
# LAYER_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
LCONF_VERSION = "6"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
    ${TOPDIR}/../layers/poky/meta \
    ${TOPDIR}/../layers/poky/meta-yocto \
    ${TOPDIR}/../layers/meta-openembedded/meta-oe \
    ${TOPDIR}/../layers/meta-openembedded/meta-filesystems \
    ${TOPDIR}/../layers/meta-openembedded/meta-networking \
    ${TOPDIR}/../layers/meta-openembedded/meta-python \
    ${TOPDIR}/../layers/meta-openembedded/meta-perl \
    ${TOPDIR}/../layers/meta-virtualization \
    ${TOPDIR}/../layers/meta-edgeos/meta-edgeos-common \
    ${TOPDIR}/../layers/meta-edgeos/meta-edgeos-pyro \
    ${TOPDIR}/../layers/meta-edgeos-qemu \
    ${TOPDIR}/../layers/oe-meta-go \
    ${TOPDIR}/../layers/meta-swupdate \
    ${TOPDIR}/../layers/meta-security \
    ${TOPDIR}/../layers/meta-security/meta-tpm \
    ${TOPDIR}/../layers/meta-platform-management/meta-edgeos \
    ${TOPDIR}/../layers/meta-platform-management/meta-platform-management-common \
    ${TOPDIR}/../layers/meta-bootloader/meta-edgeos \
    ${TOPDIR}/../layers/meta-bootloader/meta-bootloader-common \
    ${TOPDIR}/../layers/meta-greengrass/meta-edgeos \
    ${TOPDIR}/../layers/meta-greengrass/meta-greengrass-common \
    "

BBLAYERS_NON_REMOVABLE ?= " \
    ${TOPDIR}/../layers/poky/meta \
    ${TOPDIR}/../layers/poky/meta-yocto \
    ${TOPDIR}/../layers/meta-edgeos/meta-edgeos-common \
    "
~~~

If you are building for Raspberry Pi 3 (in EdgeOS context) then also add:

~~~
${TOPDIR}/../layers/meta-greengrass/meta-edgeos-raspberrypi \
~~~

on a new line, after:

~~~
${TOPDIR}/../layers/meta-greengrass/meta-greengrass-common \
~~~



## Configuring Greengrass

**Configuration File**

You will need to add your device configuration information in the greengrass configuration file.

You can either modify  ```src/layers/meta-greengrass/meta-greengrass-common/recipes-core/greengrass/greengrass/config.json``` to build (some or all) of your configuration into EdgeOS, or else use ```SSH``` or ```SCP```  to modify ```/greengrass/config/config.json``` on the resulting image.

For information how to complete config file see the [Greengrass Developer Guide -- Configure the AWS Greengrass Core](https://docs.aws.amazon.com/greengrass/latest/developerguide/gg-core.html).

***NOTE!*** Pay particular attention to the file permission process in the _Configure a Write Directory for AWS Greengrass_ section in the Greengrass Developer Guide page provided above. In the EdgeOS context you **MUST** use the `writeDirectory` configuration option and provide a path under `/mnt/data`, because the root filesystem is read-only. For example:

~~~bash
$ systemctl stop greengrassd
$ mount -o remount,rw /
# Make changes to /greengrass/config/config.json, then
$ chmod 0600 /greengrass/config/config.json
# Continued below ...
~~~



**Certificates**

Get your device certificates by following the instructions for [creating a new Greengrass core](https://docs.aws.amazon.com/greengrass/latest/developerguide/gg-config.html).

Download the root-ca cert for AWS by:

~~~bash
wget -O root.ca.pem http://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem
~~~

and place all 4 of the files into ```/greengrass/certs/``` on EdgeOS.

***NOTE!*** As mentioned above, in the EdgeOS context the root filesystem is read-only so you must follow the instructions on [Greengrass Developer Guide -- Configure the AWS Greengrass Core](https://docs.aws.amazon.com/greengrass/latest/developerguide/gg-core.html), especially those pertaining to file permissions. For example:

~~~bash
# ...continued from above
# Copy your the 4 certs into /greengrass/certs, then
$ chown -R ggc_user:ggc_group /greengrass/certs/
$ chown -R ggc_user:ggc_group /greengrass/ggc/packages/1.6.0/lambda/
$ mount -o remount,ro /
$ systemctl start greengrassd
~~~




## Greengrass Lambda Opcode error in QEMU

If your Greengrass lambda fails with an error such as the one below in ```Journalctl```:

~~~
Mar 12 22:42:22 edgeos kernel: traps: python2.7[2169] trap invalid opcode ip:7fd273ba4a3b sp:7ffe1dec9860 error:0
Mar 12 22:42:22 edgeos kernel:  in strop.so[7fd273ba3000+6000]
Mar 12 22:42:22 edgeos audit[2169]: ANOM_ABEND auid=4294967295 uid=990 gid=984 ses=4294967295 pid=2169 comm="python2.7" exe="/usr/bin/python2.7" sig=4
~~~

then add one or both of the following to your QEMU launch command: ```-cpu core2duo``` and/or ```-enable-kvm```/

## Philosophy of Use on EdgeOS

It is important to realize that Greengrass lambdas are very general tools and can be used on EdgeOS in a manner that is not inline with our philosophy of running containerized apps. Lambdas, however, are a very powerful tool can very naturally be used within the EdgeOS philosophy; it is up to the developers and admins to use Lambdas appropriately.

By way of example, when following the Greengrass Developer Guide you will learn how to launch lambdas on EdgeOS. These lambdas will run inside a special containers managed by Greengrass only. These lambda-containers can use system libraries and will work just fine for the simple examples in the guide, meanwhile, EdgeOS is minimal by design and so it is quite likely that system- and 3rd-party- libraries that your lambda requires are not included in the OS. The strategy with lambda dependencies, therefore, is to package all dependencies within the Lambda.  However, this becomes challenging when there are a lot of dependencies and especially challenging when when some dependencies are compiled system libraries.

Furthermore, it is important to note that lamdbas are not monitored or controlled by the Container App Service EdgeOS service. While, lambdas are authenticated and monitored by Greengrass, this diverges from the philosophy of use for EdgeOS.

It is for this reason that we designed EdgeOS to deploy applications using containers managed by the Container App Service. Therefore, we recommend only using lambdas to command the built in EdgeOS services or for simple actions for which containers may not be ideal. For example, a lambda can be written to command a system update using the Software Update Service which is built into EdgeOS. Additionally, the lambda function can communicate with the Container App Service to download and launch an app. By using the AWS SDK libraries, your containerized apps launched in this manner can authenticate, communicate, and receive commands from other AWS services.

In this manner you will build a library of lambdas in your AWS Console which you will use to perform preprogrammed actions on some or all of your Greengrass enabled devices. You will then have records and logs of which actions (lambdas) were run on each device, at what times, and by whom.
