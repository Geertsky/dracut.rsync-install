#: -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh
check() {
  return 0
}
depends() {
  return 0
}
install() {

  inst_multiple expr wget tar cpio gzip modprobe touch echo
  inst_multiple head tail socat basename sha1sum bc chmod ifconfig hostname awk egrep dirname cut wc xz grep ldconfig sort rsync date sync bash true clear xsltproc tr tee lvm parted mdadm lsof debugfs dumpe2fs e2freefrag e2fsck e2image e2label e2undo e4defrag filefrag fsck.ext2 fsck.ext3 fsck.ext4 mke2fs mkfs.ext2 mkfs.ext3 mkfs.ext4 resize2fs tune2fs dosfsck dosfslabel fatlabel fsck.fat fsck.msdos fsck.vfat mkdosfs mkfs.fat mkfs.msdos mkfs.vfat ksflatten ksshell ksvalidator ksverdiff fallocate findmnt getopt lsblk addpart blkdiscard blkid blockdev cfdisk delpart fdformat fdisk findfs fsck fsck.cramfs fsck.minix fsfreeze fstrim ldattach losetup mkfs mkfs.cramfs mkfs.minix mkswap partx resizepart sfdisk swaplabel swapoff swapon wipefs multipath host hostname mkdosfs mkfs mkfs.cramfs mkfs.ext2 mkfs.ext3 mkfs.ext4 mkfs.minix mkfs.msdos mkfs.vfat mkfs.xfs xfs_admin mkswap tune2fs

  inst_simple /usr/lib64/python2.7/encodings/utf_8.py
  inst /usr/lib64/python2.7/encodings/utf_8.pyc
  inst_library /usr/lib64/python2.7/lib-dynload/resource.so
  inst_simple /usr/lib64/python2.7/site-packages/abrt_exception_handler.py
  inst /usr/lib64/python2.7/site-packages/abrt_exception_handler.pyc
  inst /usr/lib64/python2.7/site-packages/abrt.pth
  inst /usr/lib64/python2.7/site-packages/pygtk.pth
  inst /usr/lib/locale/locale-archive
  inst /usr/lib/python2.7/site-packages/openlmi-0.5.0-py2.7-nspkg.pth
  inst /usr/lib/python2.7/site-packages/openlmi_software-0.5.0-py2.7-nspkg.pth
  inst /usr/lib/python2.7/site-packages/openlmi_storage-0.8.0-py2.7-nspkg.pth
  #needed for NSS needed by blivet
  inst /usr/lib64/libsoftokn3.so

  #needed for blivet
  inst /usr/lib/rpm/rpmrc

  inst_multiple /etc/python /etc/tmpfiles.d/python.conf

  PYTHONHASHSEED=42 $moddir/python-deps $moddir/check_and_format_disks.py $moddir/multicast_receiver.py $moddir/sendmail.py | while read dep; do
    case "$dep" in
    *.so) inst_library $dep ;;
    *.py) inst_simple $dep ;;
    check_and_format_disks.py) ;;
    *) inst $dep ;;
    esac
  done
  inst $moddir/check_and_format_disks.py /lib/check_and_format_disks.py
  inst $moddir/multicast_receiver.py /lib/multicast_receiver.py
  inst "$moddir"/xcat-updateflag "/tmp/updateflag"
  inst $moddir/sendmail.py /usr/bin/sendmail.py

  inst_hook cmdline 20 "$moddir"/rsync-install-cmdline.sh
  inst_hook initqueue/online 20 "$moddir"/rsync-install-initqueue_online_getXML.sh
  inst_hook pre-mount 20 "$moddir"/rsync-install-pre-mount_partition-disks.sh
  inst_hook pre-mount 30 "$moddir"/rsync-install-pre-mount_mount-disks.sh
  inst_hook pre-mount 40 "$moddir"/rsync-install-pre-mount_sync.sh
  inst_hook cleanup 20 "$moddir"/rsync-install-cleanup_save-logs-to-sysroot.sh
}
