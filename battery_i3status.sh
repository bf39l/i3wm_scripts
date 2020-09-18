#!/bin/sh

# Authors:
# - Moritz Warning <moritzwarning@web.de> (2016)
# - Zhong Jianxin <azuwis@gmail.com> (2014)
#
# See file LICENSE at the project root directory for license information.
#
# i3status.conf should contain:
# general {
#   output_format = i3bar
# }
#
# i3 config looks like this:
# bar {
#   status_command exec /usr/share/doc/i3status/contrib/net-speed.sh
# }
#
# Single interface:
# ifaces="eth0"
#
# Multiple interfaces:
# ifaces="eth0 wlan0"
#

# Auto detect interfaces
ifaces=$(ls /sys/class/net | grep -E '^(eno|enp|ens|enx|eth|wlan|wlp)')

last_time=0
last_rx=0
last_tx=0
rate=""
battery=""

readable() {
  local bytes=$1
  local kib=$(( bytes >> 10 ))
  if [ $kib -lt 0 ]; then
    echo "? K"
  elif [ $kib -gt 1024 ]; then
    local mib_int=$(( kib >> 10 ))
    local mib_dec=$(( kib % 1024 * 976 / 10000 ))
    if [ "$mib_dec" -lt 10 ]; then
      mib_dec="0${mib_dec}"
    fi
    echo "${mib_int}.${mib_dec} M"
  else
    echo "${kib} K"
  fi
}

update_rate() {
  local time=$(date +%s)
  local rx=0 tx=0 tmp_rx tmp_tx

  for iface in $ifaces; do
    read tmp_rx < "/sys/class/net/${iface}/statistics/rx_bytes"
    read tmp_tx < "/sys/class/net/${iface}/statistics/tx_bytes"
    rx=$(( rx + tmp_rx ))
    tx=$(( tx + tmp_tx ))
  done

  local interval=$(( $time - $last_time ))
  if [ $interval -gt 0 ]; then
    rate="$(readable $(( (rx - last_rx) / interval )))↓ $(readable $(( (tx - last_tx) / interval )))↑"
  else
    rate=""
  fi

  last_time=$time
  last_rx=$rx
  last_tx=$tx
}

battery_info() {
	BATTERY=0
	BATTERY_INFO=$(acpi --battery | grep "Battery ${BATTERY}")
	BATTERY_STATE=$(echo "${BATTERY_INFO}" | grep -wo "Full\|Charging\|Discharging")
	BATTERY_POWER=$(echo "${BATTERY_INFO}" | grep -o '[0-9]\+%' | tr -d '%')
	BATTERY_ICON=0
	BATTERY_COLOR="#ffffff"

	URGENT_VALUE=10

	if [ "${BATTERY_POWER}" -le "${URGENT_VALUE}" ]; then
		BATTERY_ICON=""
		BATTERY_COLOR="#ff0000"
	elif [ "${BATTERY_POWER}" -le 25 ]; then
    BATTERY_ICON=""
 		BATTERY_COLOR="#fc5353"
	elif [ "${BATTERY_POWER}" -le 50 ]; then
    BATTERY_ICON=""
    BATTERY_COLOR="#ffbb84"
	elif [ "${BATTERY_POWER}" -le 80 ]; then
    BATTERY_ICON=""
    BATTERY_COLOR="#ffbb84"
	else
    BATTERY_ICON=""
    BATTERY_COLOR="#ffffff"
	fi

	if [ "${BATTERY_STATE}" = "Charging" ]; then
	  battery="\"<span background='#a5a5a5'> ${BATTERY_ICON} ${BATTERY_POWER}%↑ </span>\", \"color\":\"${BATTERY_COLOR}\", \"markup\":\"pango\""
	elif [ "${BATTERY_STATE}" = "Discharging" ]; then
    battery="\"<span background='#a5a5a5'> ${BATTERY_ICON} ${BATTERY_POWER}%↓ </span>\", \"color\":\"${BATTERY_COLOR}\", \"markup\":\"pango\""
	else
    battery="\"<span background='#a5a5a5'> ${BATTERY_ICON} ${BATTERY_POWER}%X </span>\", \"color\":\"${BATTERY_COLOR}\", \"markup\":\"pango\""
	fi

	#if [ "${BATTERY_POWER}" -le "${URGENT_VALUE}" ]; then
  	#exit 33
	#fi
}

i3status | (read line && echo "$line" && read line && echo "$line" && read line && echo "$line" && while :
do
  read line
  # update_rate
  battery_info
  # echo ",[{\"full_text\":\"${battery}\" },${line#,\[}" || exit 1
  # echo ",[{\"full_text\":${battery} },${line#,\[}" || exit 1
  # echo "************"
  #echo ${line%?} # remove last char
  # echo "#########"
  echo "${line%?},{\"full_text\":${battery} }]" || exit 1
done)
