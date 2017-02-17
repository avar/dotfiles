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
def oi_work_gmail_local_nametrans(name):
    name = re.sub('^Drafts$', '[Gmail]/Drafts',    name)
    name = re.sub('^Sent$',   '[Gmail]/Sent Mail', name)
    name = re.sub('^Junk$',   '[Gmail]/Spam',      name)
    name = re.sub('^Trash$',  '[Gmail]/Trash',      name)

    return name

def oi_work_gmail_remote_nametrans(name):
    name = re.sub('^\[Gmail\]/Drafts$',    'Drafts', name)
    name = re.sub('^\[Gmail\]/Sent Mail$', 'Sent',   name)
    name = re.sub('^\[Gmail\]/Spam$',      'Junk',   name)
    name = re.sub('^\[Gmail\]/Trash$',     'Trash',  name)

    return name
