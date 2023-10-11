#!/usr/bin/python
# Import smtplib for the actual sending function
import sys,os
import smtplib
smtpserver=sys.argv[1]
fromaddr=sys.argv[2]
toaddr=sys.argv[3]
# Import the email modules we'll need
from email.mime.text import MIMEText

# the text file contains only ASCII characters.
# Create a text/plain message
msg = MIMEText(sys.stdin.read())
msg['Subject'] = 'sync failed on '+os.environ.get("HOSTNAME")
msg['From'] = fromaddr
msg['To'] = toaddr 

# Send the message via our own SMTP server, but don't include the
# envelope header.
s = smtplib.SMTP(smtpserver)
s.sendmail(fromaddr,toaddr.split(";"),msg.as_string())
s.quit()
