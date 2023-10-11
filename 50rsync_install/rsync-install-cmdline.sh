root=1
rootok=1
echo '[ -f /tmp/parameters.xml ]' >$hookdir/initqueue/finished/parameters.sh
echo '[ -e /tmp/xsl ]' >$hookdir/initqueue/finished/xsl.sh
#remove xcat waiting for a mounted proc as it gets mounted later...
rm /lib/dracut/hooks/initqueue/finished/xcatroot.sh
cat <<EOT >/sbin/xcatroot
#!/bin/sh


NEWROOT=\$3
RWDIR=.statelite
XCATMASTER=\$XCAT

. /lib/dracut-lib.sh
rootlimit="\$(getarg rootlimit=)"


getarg nonodestatus
NODESTATUS=\$?

MASTER=\`echo \$XCATMASTER |awk -F: '{print \$1}'\`
XCATIPORT="\$(getarg XCATIPORT=)"
if [ \$? -ne 0 ]; then
XCATIPORT="3002"
fi


xcatdebugmode="\$(getarg xcatdebugmode=)"


[ "\$xcatdebugmode" > "0" ] && logger -t xcat -p debug "running xcatroot...."
[ "\$xcatdebugmode" > "0" ] && logger -t xcat -p debug "MASTER=\$MASTER XCATIPORT=\$XCATIPORT"


if [ "\$NODESTATUS" != "0" ]; then
[ "\$xcatdebugmode" > "0" ] && logger -t xcat -p debug "nodestatus: netbooting,reporting..."
/tmp/updateflag \$MASTER \$XCATIPORT "installstatus netbooting"
fi

[ "\$xcatdebugmode" > "0" ] && logger -t xcat -p debug "exiting xcatroot..."
# inject new exit_if_exists
echo 'settle_exit_if_exists="--exit-if-exists=/dev/root"; rm "\$job"' > \$hookdir/initqueue/xcat.sh
# force udevsettle to break
> \$hookdir/initqueue/work

EOT
