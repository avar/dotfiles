# This does tilde (~) expansion which python's open() doesn't do
# natively.
from os.path import expanduser
import re

def get_password(what):
    path = expanduser("~/.password/" + what)
    fh = open(path)
    # rstrip() = chomp()
    content = fh.read().rstrip()
    fh.close()

    return content

# Any rule added to one of these subs needs an inverse rule in the
# other one.
def oi_work_local_nametrans(name):
    name = re.sub('^Sent$',  'Sent Items',    name)
    name = re.sub('^Trash$', 'Deleted Items', name)
    name = re.sub('^Junk$',  'Junk E-Mail',   name)

    return name

def oi_work_remote_nametrans(name):
    name = re.sub('^Sent Items$',    'Sent',  name)
    name = re.sub('^Deleted Items$', 'Trash', name)
    name = re.sub('^Junk E-Mail$',   'Junk',  name)

    return name
