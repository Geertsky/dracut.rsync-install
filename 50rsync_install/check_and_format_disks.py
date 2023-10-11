#!/usr/bin/python
import blivet
import xml.etree.ElementTree as ET
import urllib2
from decimal import *

import os,sys

b = blivet.Blivet()
action="check"
if len(sys.argv) >=2:
	action=sys.argv[1]
XML=open("/tmp/parameters.xml").read()
XMLnode=ET.fromstring(XML)
disks=XMLnode.findall("disk")
try:
	debug=os.environ['debug']
except KeyError:
	debug=False
b.reset()
b.devicetree.reset()	
def check_disk(disk):
	result=True
	XMLdevice=disk.find("device").text
	b.devicetree.reset()
	if not b.devicetree.populated:
		b.devicetree.populate()
	XMLnr=1
	for partition in disk.findall("partition"):
		#Extract info from XML
		XMLfault=blivet.Size(partition.find("fault").text)
		XMLsize=blivet.Size(partition.find("size").text)
		XMLformat=partition.find("format").text
		uuid=partition.find("uuid")
		if uuid != None:
			XMLuuid=uuid.text
		else:
			XMLuuid=uuid
		label=partition.find("label")
		if label != None:
            		XMLlabel=label.text
		else:
            		XMLlabel=label
		#compare size of device with size defined in XML
		device=None
		deviceSize=blivet.Size("0 B")
		difference=blivet.Size(str(sys.maxint)+" B")
		try:
			if b.devicetree.getDeviceByPath(XMLdevice+str(XMLnr)).isExtended == long(2):
				XMLnr+=1
				continue #a extended partition is the only partition where isExtended==2L
			device=b.devicetree.getDeviceByPath(XMLdevice+str(XMLnr)).dict
			deviceSize=device["size"]
			difference=deviceSize-XMLsize
		except:
			#If device doesn't exsist at all, set difference to nonsense too big value so its always too big.
			difference=blivet.Size(str(sys.maxint)+' B')
		if difference < 0:
			difference=difference*-1
		if debug:
			print("XMLpartition:",XMLdevice+str(XMLnr))
			print("device['format']['device']:", device['format']['device'])
			print("XMLfault:",XMLfault)
			print("XMLsize:",XMLsize)
			print("device['size']:", device['size'].to_eng_string())
			print("XMLformat:",XMLformat)
			print("device['format']['name']:", device['format']['name'])
			print("XMLlabel:",XMLlabel)
			try:
				print("device['format']['label']:", device['format']['label'])
			except KeyError:
				print "No label on partition"
		if result and difference >= XMLfault:
			print("deviceSize:", deviceSize.to_eng_string())
			print("XMLsize:", XMLsize.to_eng_string())
			print("Difference:",difference,"is more then", XMLfault)
			result=False
		#partition size is ok
		if result and XMLlabel != None:
			try:
				if device['format']['label'] != XMLlabel:
					print("label of "+str(device['format']['device'])+" is "+str(device['format']['label'])+" were "+str(XMLlabel)+" was expected.")
					result=False
			except KeyError:
				print "No label on partition"
				result=False
		if result and XMLuuid != None:
			try:
				if device['format']['uuid'] != XMLuuid:
					print("uuid of "+str(device['format']['device'])+" is "+str(device['format']['uuid'])+" were "+str(XMLuuid)+" was expected.")
					result=False
			except KeyError:
                                print "No uuid on partition"
                                result=False
		if XMLnr==3:
			XMLnr+=2
		else:
			XMLnr+=1	
	return(result)

def reformat_disk(disk):
	os.system("touch /tmp/useImage")
	XMLdevice=disk.find("device").text
	b.reset()
	if not b.devicetree.populated:
		b.devicetree.populate()
	device=b.devicetree.getDeviceByPath(XMLdevice)
	b.recursiveRemove(device)
	b.doIt()
	b.initializeDisk(device)
	#possible to change partition label HERE
	#till then old remains 
	#device.format.create()
	partnr=1
	for partition in disk.findall("partition"):
		label=None
		uuid=None
		XMLsize=blivet.Size(partition.find("size").text)
		#XMLtype=partition.find("type").text
		XMLformat=partition.find("format").text
		if XMLformat == "ext2" or XMLformat == "ext3" or XMLformat == "ext4":
			UUIDset="tune2fs -U "
		elif XMLformat == "swap":
			UUIDset="swaplabel -U "
		elif XMLformat == "xfs":
			UUIDset="xfs_admin -U"
		#partnr=partition.find("nr").text
		uuid=partition.find("uuid")
		if uuid != None:
			XMLuuid=unicode(uuid.text)
		label=partition.find("label")
		dev=b.newPartition(fmt_type=XMLformat, size=XMLsize, parents=[device])
		if label != None:
			dev.format.label=label.text
		b.createDevice(dev)
		blivet.partitioning.doPartitioning(b)
		b.doIt()
		print "Label:", label.text
		if XMLformat == "swap":
			CMD="mkswap"
			if label is not None:
				CMD+=" -L "+label.text
			if uuid is not None:
				CMD+=" -U "+XMLuuid 
			CMD+=" "+XMLdevice+str(partnr)
			print "Executing:",CMD
			os.system(CMD)
		if uuid != None:
			print "Executing:",UUIDset+XMLuuid+" "+XMLdevice+str(partnr)
			os.system(UUIDset+XMLuuid+" "+XMLdevice+str(partnr))
		if partnr==3:
			partnr+=2
		else:
			partnr+=1
		
for disk in disks:
	if action == "format":
		reformat_disk(disk)
	else:
		#check_disk(disk)
		if not check_disk(disk):
			print("reformating disk"+disk.find("device").text)
			reformat_disk(disk)
		else:
			print("partitons on disk "+disk.find("device").text+" seem OK")
