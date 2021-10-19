#!/bin/sh
set -e

for i in $(seq 1 3)
do
	target="/dev/video$i"
	if test -e $target && ! test -h $target
	then
		sudo mv -v $target $target.orig
	fi
done

sudo ln -sf video2.orig /dev/video0
v4l2-ctl --set-fmt-video=width=1280,height=960
