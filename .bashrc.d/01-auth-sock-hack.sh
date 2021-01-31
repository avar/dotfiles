#!/bin/sh

# Fix up SSH_AUTH_SOCK
auth_sock_hack() {
    # Just call this when I use "git" or "ssh" interactively, not when
    # e.g. git-prompt calls us. The callstack is two because it's this
    # file twice, once for each frame.
    if test ${#BASH_SOURCE[@]} -gt 2
    then
        return
    fi

    ## Get the most recent still alive socket owned by me in /tmp
    good_socket=$(perl -wle 'print +(sort({ (stat($b))[10] <=> (stat($a))[10] } grep -O, glob shift))[0]' '/tmp/ssh*/*agent*')

    if test -n "$good_socket"
    then
        ln -sf $good_socket ~/.ssh_auth_sock
        export SSH_AUTH_SOCK=~/.ssh_auth_sock
    fi
}

if test $HOSTNAME = "vm.nix.is"
then
    git() {
        auth_sock_hack;
        command git "$@"
    }
    ssh() {
        auth_sock_hack;
        command ssh "$@"
    }
fi
