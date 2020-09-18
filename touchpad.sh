#!/bin/sh
touchpad_info() {
    # VAL=0
    INFO=$(synclient -l | grep "TouchpadOff")
    VAL=$(echo "${INFO}" | grep -o '[0-9]')

    if [ "${VAL}" -eq 0 ]; then
        notify-send "Touchpad Disabled" -t 1000
        echo 1
    else
        notify-send "Touchpad Enabled" -t 1000
        echo 0
    fi
}

touchpad_info