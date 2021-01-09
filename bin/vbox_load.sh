#!/bin/bash

# Startup the VirtualBox client utils
VBoxClient-all
VBoxClient --vmsvga

# Reset the background after res change
nitrogen --restore
