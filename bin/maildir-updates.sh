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

sleep=${SLEEP:-60}
sleep_step=$(($sleep / 2))
min_sleep=$sleep_step
max_sleep=$(($sleep * 10))

tmpd=$(mktemp -d $XDG_RUNTIME_DIR/$(basename $0)-XXXXX)

cd ~/Maildir
while true
do
	updates=$(($sleep + 2))
	{
		tree $tree_opts * >$tmpd/a
		echo update $tmpd/a

		for i in $(seq 1 $sleep)
		do
			echo update $i
			sleep 1
		done
		tree $tree_opts * >$tmpd/b
		echo update $tmpd/b
	}  | pv -l -N "waiting with sleep of ${sleep}s, oscillating from ${min_sleep}s..${max_sleep}s" -s "$updates" >/dev/null

	if git -P diff --exit-code --no-index $tmpd/[ab]
	then
		# no changes
		if test $sleep -lt $max_sleep
		then
			sleep=$(($sleep + $sleep_step))
		fi
	else
		# changes
		if test $sleep -gt $min_sleep
		then
			sleep=$(($sleep - $sleep_step))
		fi
	fi
done

cleanup
