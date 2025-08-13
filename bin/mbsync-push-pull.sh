#!/bin/bash

while true
do
	echo "(Re)starting mbsync $*" >&2
	mbsync $@

	sleep 7
done
