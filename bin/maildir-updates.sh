#!/bin/sh
set -e

if test -z "$XDG_RUNTIME_DIR"
then
	echo "Should have $XDG_RUNTIME_DIR set to /run/user/<id>"
	exit 1
fi

tmpd=
cleanup () {
	if test -n "$tmpd"
	then
		rm -rf "$tmpd"
		tmpd=
	fi
}
trap 'cleanup' EXIT
trap 'cleanup' INT

tree_opts="-sfhi --du"
sleep=${SLEEP:-30}
tmpd=$(mktemp -d $XDG_RUNTIME_DIR/$(basename $0)-XXXXX)

cd ~/Maildir
while true
do
	tree $tree_opts * | pv -l -N "*/a" >$tmpd/a
	for i in $(seq 1 $sleep)
	do
		echo update
		sleep 1
	done | pv -l -N "waiting" -s "$sleep" >/dev/null
	tree $tree_opts * | pv -l -N "*/b" >$tmpd/b

	git -P diff --no-index $tmpd/[ab]
done

cleanup
