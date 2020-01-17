#!/bin/bash

# Ordering is important, appears to be a race condition
#VBoxClient --clipboard
#VBoxClient --display
#VBoxClient --vmsvga

#gnome-session
xcompmgr &

[ ! -x "$(which nitrogen)" ] || nitrogen --restore
