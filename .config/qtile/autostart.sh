#!/bin/bash

# Try to start gnome-session or at least the settings daemon
#[[ -x "/usr/bin/gnome-session" ]] && /usr/bin/gnome-session &
[[ -x "/usr/lib/gsd-xsettings" ]] && /usr/lib/gsd-xsettings &
[[ -x "/usr/lib/gnome-settings-daemon/gsd-xsettings" ]] && /usr/lib/gnome-settings-daemon/gsd-xsettings &

# Run compton or xcompmgr if available
[[ -x "/usr/bin/xcompmgr" ]] && /usr/bin/xcompmgr -f &

# Run nitrogen if available
[[ -x "/usr/bin/nitrogen" ]] && /usr/bin/nitrogen --restore

# Switch displays for widow
xrandr --output DVI-D-2 --left-of DVI-D-1

# For host `widow`, reduce mouse speed on my DeathAdder
xinput set-prop 'Razer Razer DeathAdder' 'Coordinate Transformation Matrix' 0.3 0 0 0 0.3 0 0 0 1
