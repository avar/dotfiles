#!/bin/sh

if test "$(hostname -f)" = "u.nix.is"
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
