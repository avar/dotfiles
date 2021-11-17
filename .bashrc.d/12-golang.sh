#!/bin/sh

if type go >/dev/null 2>&1
then
    export GOPATH=$HOME/gocode
    export PATH=$PATH:$GOPATH/bin

    if type parallel >/dev/null 2>&1
    then
        export GOMAXPROCS=$NPROC
    fi

    if test -d /usr/lib/go-1.16/bin
    then
	export PATH=/usr/lib/go-1.16/bin:$PATH
    fi
fi
