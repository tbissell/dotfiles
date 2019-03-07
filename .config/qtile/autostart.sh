#!/bin/bash

[[ -x "/usr/lib/gsd-xsettings" ]] && /usr/lib/gsd-xsettings &

[[ -x "/usr/bin/xcompmgr" ]] && /usr/bin/xcompmgr &

[[ -x "/usr/bin/nitrogen" ]] && /usr/bin/nitrogen --restore
