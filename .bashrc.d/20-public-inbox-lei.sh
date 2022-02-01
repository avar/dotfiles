#!/bin/sh

PU=$HOME/g/public-inbox.org
if test -d $PU
then
	export PERL5LIB=$PU/blib/lib
	maybe_add_path $PU/blib/script
fi
