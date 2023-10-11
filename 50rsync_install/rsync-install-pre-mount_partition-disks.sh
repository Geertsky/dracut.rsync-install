#!/bin/bash
#Author: Geert Geurts <geert@verweggistan.eu>
. /lib/dracut-lib.sh
getparam() {
  xsltproc /tmp/xsl/$1.xsl /tmp/parameters.xml
}

NODE=$(getarg NODE)
FULL=$(grep $NODE /tmp/xsl/fullnodes)
RAMDISK=$(getparam ramdisk)
if [ "$RAMDISK" == "true" ]; then
  rm -f /usr/lib/dracut/hooks/pre-mount/30-rsync-install-pre-mount_mount-disks.sh
  touch /tmp/useImage
  if [ -z $rootlimit ]; then
    mount -t tmpfs -o mode=755 rootfs $NEWROOT
  else
    mount -t tmpfs -o mode=755,size=$rootlimit rootfs $NEWROOT
  fi
elif [ -n "$FULL" ]; then
  python usr/lib/check_and_format_disks.py format
else
  python usr/lib/check_and_format_disks.py
fi
