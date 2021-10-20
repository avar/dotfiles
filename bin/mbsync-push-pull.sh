#!/bin/bash

while true
do
	mbsync --pull $@

	if test $(($RANDOM % 10)) -eq 0
	then
		mbsync --push $@
	fi
done
