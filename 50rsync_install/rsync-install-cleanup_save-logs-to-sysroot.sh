#!/bin/bash
mv /sysroot/var/log/rsync-install{,-$(date +%F_%T)}||mkdir /sysroot/var/log/rsync-install
test -d /sysroot/var/log/rsync-install||mkdir /sysroot/var/log/rsync-install
(rsync -av /tmp/ /sysroot/var/log/rsync-install/||true)
[ -f /run/initramfs/init.log ]&&cp /run/initramfs/init.log /sysroot/var/log/rsync-install/
[ -f /run/initramfs/rdsosreport.txt ]&&cp /run/initramfs/rdsosreport.txt /sysroot/var/log/rsync-install/
