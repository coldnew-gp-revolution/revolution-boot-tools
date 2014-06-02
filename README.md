intel-boot-tools
================

Tools to pack/unpack RAZR i bootimages

support `Moto RAZR i` /  `lenove K900`


original source

http://forum.xda-developers.com/showthread.php?t=1972589

https://github.com/turl/razr-i-boot-tools

Just run "make" to build the tools, the usage is really simple

Code:

	$ ./pack 

	Usage: ./pack original-image bzImage ramdisk output.img

	example: ./pack ./recovery.img zImage ramdisk.cpio.gz new-recovery.img 

From left to right, an already existing boot image (to copy bootstub from, it could be built from source on the future), the kernel, the gzipped cpio ramdisk and the output filename

Code:

	$ ./unpack

	Usage: ./unpack original-imgage bzImage-out ramdisk-out.cpio.gz

	example: ./unpack ./recovery.img zImage ramdisk.cpio.gz 


From left to right, the image you want to unpack, and the destination files for bzImage and ramdisk. You can then unpack the ramdisk with something like

Code:
```bash
$ mkdir ramdisk-unpack

$ cd ramdisk-unpack

$ zcat ../ramdisk.cpio.gz|cpio -i
```

And then repack it with something like
Code:

	cd ramdisk-unpack 

	$ find . | cpio -o -H newc | gzip > ../newramdisk.cpio.gz

