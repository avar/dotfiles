## renice_threads java | sudo xargs renice -n 15
renice_threads () {
	for pid in $(ps -eLf | grep "$1" | awk '{print $2}')
	do
		echo $pid
		if ! test -d "/proc/$pid/task"
		then
			continue
		fi
		for task in $(find "/proc/$pid/task" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")
		do
			if test $pid != $task
			then
				echo $task
			fi
		done
	done
}

alias renice_java='renice_threads java | sudo xargs renice -n 15'
