#!/bin/bash

gnome-session
xcompmgr &

[ ! -x "$(which nitrogen)" ] || nitrogen --restore

