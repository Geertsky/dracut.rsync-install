import socket
import struct
import sys
import os
import subprocess
filename=sys.argv[1]
master=sys.argv[2]
host=sys.argv[3]
multicast_group = '224.1.0.1'
server_address = ('', 10000)
#First notify master we're ready to receive
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((master,222))
sock.setblocking(0)
sock.sendall(host+"\n")

# Create the multicast socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Bind to the server address
sock.bind(server_address)

# Tell the operating system to add the socket to
# the multicast group on all interfaces.
group = socket.inet_aton(multicast_group)
mreq = struct.pack('4sL', group, socket.INADDR_ANY)
sock.setsockopt(
    socket.IPPROTO_IP,
    socket.IP_ADD_MEMBERSHIP,
    mreq)

# Receive/respond loop
while True:
    print('\nwaiting to receive message')
    data, address = sock.recvfrom(42)
    print "Received:",data
    if data[0:2] == "GO":
	SUM=data[2:]
	socatcmd="socat -T 1 -u UDP4-RECV:10001,ip-add-membership=224.1.0.1:eth0 CREATE:/"+filename
	p = subprocess.Popen(socatcmd, stdout=subprocess.PIPE, shell=True)
	p.wait()
    if os.popen("sha1sum /"+filename).read()[0:40] == SUM:
        print "Recieved /"+filename+" Successful!"
        break	

