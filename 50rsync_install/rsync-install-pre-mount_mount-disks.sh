#!/bin/bash
for partition in $(xsltproc /tmp/xsl/partitions-mountpoint.xsl /tmp/parameters.xml|grep -v ":$"|sort -k 1.36); do
	read UUID MNTPOINT<<<${partition/:/ }
	test -d /sysroot/$MNTPOINT||mkdir -p /sysroot/$MNTPOINT
	mount -U $UUID /sysroot/$MNTPOINT
done
