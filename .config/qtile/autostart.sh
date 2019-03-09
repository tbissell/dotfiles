#!/bin/bash

# Try to start gnome-session or at least the settings daemon
([[ -x "/usr/bin/gnome-session" ]] && /usr/bin/gnome-session &) ||
    ([[ -x "/usr/lib/gsd-xsettings" ]] && /usr/lib/gsd-xsettings &)

# Run compton or xcompmgr if available
[[ -x "/usr/bin/xcompmgr" ]] && /usr/bin/xcompmgr -f &

# Run nitrogen if available
[[ -x "/usr/bin/nitrogen" ]] && /usr/bin/nitrogen --restore
