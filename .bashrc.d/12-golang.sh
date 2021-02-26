#!/bin/sh

if type go >/dev/null 2>&1
then
    export GOPATH=$HOME/gocode
    export PATH=$PATH:$GOPATH/bin

    if type parallel >/dev/null 2>&1
    then
        export GOMAXPROCS=$(nproc)
    fi
fi
