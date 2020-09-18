#!/bin/bash

mic_info() {
	if [[ $(amixer get Capture | tail -n 1 | grep -wo 'on') == "on" ]]; then 
		notify-send "Mic ON" -t 1000
		# echo 1
	else 
		notify-send "Mic OFF" -t 1000
		# echo 0
	fi
}

mic_info
