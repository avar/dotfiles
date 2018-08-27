#!/bin/sh

# Fix up SSH_AUTH_SOCK
auth_sock_hack() {
    ## Get the most recent still alive socket owned by me in /tmp
    good_socket=$(perl -wle 'print +(sort({ (stat($b))[10] <=> (stat($a))[10] } grep -O, glob shift))[0]' '/tmp/ssh*/*agent*')

    if test -n "$good_socket"
    then
        ln -sf $good_socket ~/.ssh_auth_sock
        export SSH_AUTH_SOCK=~/.ssh_auth_sock
    fi
}
