# Meta-Greengrass Layer for EdgeOS

Builds AWS Greengrass 1.3.0 into EdgeOS.

Information about AWS IoT Greengrass can be found here: [https://aws.amazon.com/greengrass/](https://aws.amazon.com/greengrass/) and [Greengrass Developer Guide](https://docs.aws.amazon.com/greengrass/latest/developerguide/what-is-gg.html).



## Steps to Build Yocto-Qemu

Tested on [edgeos/yocto-qemu@236cccc1afeeef4c04058697f5b3e0674616aed5](https://github.com/edgeos/yocto-qemu/tree/236cccc1afeeef4c04058697f5b3e0674616aed5).

Meta-greengrass is already integrated with github.com/edgeos/yocto-qemu on branch greengrass.

~~~bash
git clone -b greengrass --recursive git@github.com:edgeos/yocto-qemu.git
cd yocto-qemu
make
~~~



## Steps to Build into Yocto-Intel

Tested on [PredixEdgeOS/yocto-intel@24a10b897585df3a8352949142c685387609b9c3](https://github.build.ge.com/PredixEdgeOS/yocto-intel/tree/24a10b897585df3a8352949142c685387609b9c3) (Currently on branch merge_rts49_jpward) 

~~~bash
git clone git@github.build.ge.com:PredixEdgeOS/yocto-intel.git yi-test
cd yocto-intel
git checkout 24a10b897585df3a8352949142c685387609b9c3
git submodule update --init --recursive
~~~



* Meta-greengrass is not built into this project yet, but can be manually added:

~~~bash
cd yocto-intel
git clone git@github.com:edgeos/meta-greengrass.git src/layers/meta-greengrass
~~~



* Apply the following diff:

~~~diff
--- a/src/layers/meta-edgeos-intel/conf/samples/bblayers.conf.sample
+++ b/src/layers/meta-edgeos-intel/conf/samples/bblayers.conf.sample
@@ -23,6 +23,7 @@ BBLAYERS ?= " \
     ${TOPDIR}/../layers/meta-swupdate \
     ${TOPDIR}/../layers/meta-security \
     ${TOPDIR}/../layers/meta-security/meta-tpm \
+    ${TOPDIR}/../layers/meta-greengrass \
     "
~~~



### Building for QEMU emulation

~~~bash
export BBOVERRIDES=":no-edge-mgmt" # If you do not want edge managament (eg egde-agent)
make
~~~



### Building for HPFA

1. Add your RTS license to ```src/layers/meta-ge-edgeos/meta-ge-edgeos-common/recipes-bsp/rth/rth/license.txt``` 
2. Apply the following diff within the meta-ge-edgeos submodule:

~~~diff
diff --git a/meta-ge-edgeos-common/recipes-kernel/linux/rts-hyper-v-4.9.inc b/meta-ge-edgeos-common/recipes-kernel/linux/rts-hyper-v-4.9.inc
index cda3e88..64614df 100644
--- a/meta-ge-edgeos-common/recipes-kernel/linux/rts-hyper-v-4.9.inc
+++ b/meta-ge-edgeos-common/recipes-kernel/linux/rts-hyper-v-4.9.inc
@@ -17,10 +17,15 @@
 #
 FILESEXTRAPATHS_prepend := "${THISDIR}/rts-hyper-v-4.9:"
 
-LINUX_VERSION_corei7-64-intel-common = "4.9.61"
-LINUX_VERSION = "4.9.61"
-SRCREV_meta = "f4e37e151102d89c4d0e110c88eb3b3c36bdeaa4"
-SRCREV_machine = "6838fc62f81f59330f720062249b4830f0161fbd"
 
 # RTS hypervisor support
 SRC_URI += " \
~~~

3. Run the build with the correct options:

   ~~~bash
   export BBOVERRIDES=":cfg-rts-hyper-v:hpfa-additive:bl-grub"
   # export BBOVERRIDES=":cfg-rts-hyper-v:hpfa-additive:bl-grub:no-edge-mgmt" if you do not want edge-mgmt (eg edge-agent)
   make
   ~~~



##Configuring Greengrass

**Configuration File**

You will need to add your device configuration information in the greengrass configuration file.

For information how to complete config file see the ```'config.json' Parameter Summary``` section [here](https://docs.aws.amazon.com/greengrass/latest/developerguide/gg-device-start.html).

You can either modify  ```src/layers/greengrass/recipes-core/greengrass/greengrass/config.json``` to build (some or all) of your configuration into EdgeOS, or else use ```SSH``` or ```SCP```  to modify ```/greengrass/config/config.json``` on the resulting image.

See the [yocto-intel README](https://github.build.ge.com/PredixEdgeOS/yocto-intel/tree/24a10b897585df3a8352949142c685387609b9c3) and/or the [yocto-qemu README](https://github.com/edgeos/yocto-qemu/tree/greengrass) for instructions on how to run the image and ```ssh``` in.

**Certificates**

Get your device certificates by following the instructions for [creating a new Greengrass core](https://docs.aws.amazon.com/greengrass/latest/developerguide/gg-config.html).

Download the root-ca cert for AWS by:

~~~bash
wget -O root.ca.pem http://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem
~~~

and place all the certs into ```/greengrass/certs/``` on EdgeOS.

See the [yocto-intel README](https://github.build.ge.com/PredixEdgeOS/yocto-intel/tree/24a10b897585df3a8352949142c685387609b9c3) and/or the [yocto-qemu README](https://github.com/edgeos/yocto-qemu/tree/greengrass) for instructions on how to run the image and ```ssh``` in.



##Outstanding Limitations with Using Greengrass on EdgeOS

The primary challenge with using Greengrass on EdgeOS is with running lambda functions with non-rudimentary dependencies. One of the advertised features of Greengrass is the ability to deploy Amazon Lambdas onto registered Greengrass Cores. However, these lambdas run directly on the OS. Meanwhile, EdgeOS is rather minimal by design and so it is quite likely that system- and 3rd-party- libraries that your lambda requires are not included. The strategy with Lambda dependencies, therefore, is to package all dependencies within the Lambda, but this becomes challanging when some dependencies are compiled libraries.

It is for this reason that we designed EdgeOS to deploy applications using containers. 
