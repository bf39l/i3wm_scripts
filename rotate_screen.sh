#!/bin/sh
# invert_screen
#orientation="$(xrandr -q | grep "eDP-1 connected" | awk '{print $5}')"
orientation=$(xrandr -q | grep "eDP-1 connected" | cut -d '(' -f 1 | grep -wo inverted)
echo $orientation
display="eDP-1"
if [ "$orientation" = "inverted" ]; then
   xrandr --output $display --rotate normal
else
   xrandr --output $display --rotate inverted
fi
