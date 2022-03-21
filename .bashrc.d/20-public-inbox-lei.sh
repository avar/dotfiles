#!/bin/sh

PU=$HOME/g/public-inbox.org
if test -d $PU
then	. $PU/contrib/completion/lei-completion.bash

	# To avoid buildig the software in blib/, makes debugging
	# easier.
	lei () {
		perl -I $PU/lib $PU/script/lei "$@"
	}

	public-inbox () {
		cmd=$1 &&
		shift &&
		perl -I $PU/lib $PU/script/public-inbox-$cmd "$@"
	}
fi

