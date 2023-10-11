. /lib/dracut-lib.sh
XCAT=$(getarg XCAT)
XCAT=${XCAT%:*}
NODE=$(getarg NODE)
TYPE=$(echo $NODE|sed -r 's/[0-9]*$//')
if wget -q --spider $XCAT/install/nodes-parameters/$NODE.xml; then URL="$XCAT/install/nodes-parameters/$NODE.xml";
elif wget -q --spider $XCAT/install/nodes-parameters/$TYPE.xml; then URL="$XCAT/install/nodes-parameters/$TYPE.xml";
else URL="$XCAT/install/nodes-parameters/default.xml"
fi
wget -q -O /tmp/parameters.xml $URL
wget -q -P /tmp/xsl -r -nH -nd -np -R index.html* $XCAT/install/nodes-parameters/xsl
