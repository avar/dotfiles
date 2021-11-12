#!/bin/bash

while true
do
	timeout 5m mbsync $@

	sleep 7
done
