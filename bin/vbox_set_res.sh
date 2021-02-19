#!/bin/bash

xrandr --newmode "1920x1080_60.00"  172.80  1920 2040 2248 2576  1080 1081 1084 1118
xrandr --addmode Virtual1 1920x1080_60.00
xrandr -s 1920x1080_60
nitrogen --restore
