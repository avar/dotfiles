# This does tilde (~) expansion which python's open() doesn't do
# natively.
from os.path import expanduser

def get_password(what):
    path = expanduser("~/.password/" + what)
    fh = open(path)
    # rstrip() = chomp()
    content = fh.read().rstrip()
    fh.close()

    return content
