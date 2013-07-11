import os
from ftplib import FTP
import sys

host = sys.argv[1];
remote_dir = sys.argv[2];
local_dir = sys.argv[3];
ext = sys.argv[4];

if len(sys.argv) == 7:
    username = sys.argv[5]
    password = sys.argv[6]
else:
    username = "anonymous"
    password = "anonymous@"

ftp = FTP(host)
ftp.login(username, password)

ftp.cwd(remote_dir)

listing = []
ftp.retrlines("LIST", listing.append)
filenames = [item.split(None, 8)[-1].lstrip() for item in listing]
filenames = filter(lambda filename: filename.lower().endswith(ext.lower()), filenames)

for filename in filenames:
    print('FTP ' + filename)
    local_filename = os.path.join(local_dir, filename)
    lf = open(local_filename, "wb")
    ftp.retrbinary("RETR " + filename, lf.write, 8*1024)
    lf.close()
