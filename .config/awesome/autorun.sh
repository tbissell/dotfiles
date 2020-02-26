#!/bin/bash

# Ordering is important, appears to be a race condition
#VBoxClient --clipboard
#VBoxClient --display
#VBoxClient --vmsvga

#gnome-session
xcompmgr &

[ ! -x "$(which nitrogen)" ] || nitrogen --restore

# Switch displays for widow
xrandr --output DVI-D-2 --left-of DVI-D-1

# For host `widow`, reduce mouse speed on my DeathAdder
xinput set-prop 'Razer Razer DeathAdder' 'Coordinate Transformation Matrix' 0.3 0 0 0 0.3 0 0 0 1
