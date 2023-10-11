#!/bin/bash 
#Author: Geert Geurts <geert.geurts@dalco.ch>
getparam() {
xsltproc /tmp/xsl/$1.xsl /tmp/parameters.xml
}
. /lib/dracut-lib.sh
[ "$debug" ]&&echo "rsync_install: Running rsync..."
XCAT=$(getarg XCAT)
XCAT=${XCAT%:*}
PROVNODE=$(getparam provnode)
IMAGE="$(getparam image)"
IMAGE=$(echo $IMAGE|sed 's/\/$//') #remove trailing slash of image...
ROOT="$(getparam root)"
MULTICAST="$(getparam multicast)"
ROOTMNT=/sysroot
ROOTIMGDIR="$(getparam rootimgdir)"
RSYNCARGS="$(getparam rsyncargs|tr '_' ' ')"
RSYNCPORT="$(getparam rsyncport)"
IMGURL=$(getarg imgurl)
NODE=$(getarg NODE)
IP="$(ip route get $XCAT|awk -v XCAT=$XCAT '{if ($1==XCAT) print $NF}')"
ADMINMAIL=$(getparam adminmail)
FROMMAIL=$(getparam frommail)
SMTPSERVER=$(getparam smtpserver)
[ -z "$PROVNODE" ]&&PROVNODE=$XCAT
[ -z "$SMTPSERVER" ]&&SMTPSERVER=$XCAT
[ -z "$RSYNCPORT" ]&&RSYNCPORT=22
[ -z "$RSYNCARGS" ]&&RSYNCARGS="-zaSH -vv --stats --human-readable"	
[ -z "$MULTICAST" ]&&MULTICAST=0
[ -z "$FROMMAIL" ]&&FROMMAIL=root@$NODE
export HOSTNAME=$NODE
case $MULTICAST in
  false)
	(
	if [ -f /tmp/useImage ]; then
		cd /sysroot
		wget -O- $IMGURL|gzip -cd -|cpio -id
		exit 0
	fi
	SUCCESS="False"
	while [ -n "$SUCCESS" ]; do
		rsync $RSYNCARGS rsync://root@$PROVNODE/$IMAGE/ /sysroot/ 2>/tmp/rsync.err
		R=$?
		if [ $R -ne 0 ]; then
			echo "Rsync install of node $NODE Failed"|/usr/bin/sendmail.py $SMTPSERVER $FROMMAIL "$ADMINMAIL"
			echo "rsync exited non-zero..."
			/bin/bash
		fi
		SUCCESS=$(grep -E "ERROR: max connections \([0-9]+\) reached" /tmp/rsync.err)
		if [ -n "$SUCCESS" ]; then 
			sleep 5
		fi
	done
	clear
        ) |tee /tmp/rsync.log|sed -n '0~500p'
	if [ $? != 0 ]; then
		echo "rsync finished with a non zero exit status..."
		echo "faling back to bash for debugging..."
		/bin/bash
		exit 1
	fi
	clear
	;;
  true)
	MCIF=$(getparam mcif)
	[ -z "$MCIF" ]&&MCIF=eth0
	FILENAME=$(basename $IMGURL)
	ip route add 224.0.0.0/4 dev $MCIF
	python /lib/dalco/dalco-multicast_receiver.py $FILENAME $XCAT $NODE
	cd /sysroot
	gzip -cd /$FILENAME|cpio -id
	echo 'Muticast install finished!'
	;;
esac
mount --bind /dev /sysroot/dev
mount --bind /sys /sysroot/sys
mount --bind /proc /sysroot/proc
