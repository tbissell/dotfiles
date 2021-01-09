#!/bin/bash

BASEDIR="$HOME/.local/var/notes"
FILE="$BASEDIR/note-$(date -I).md"

# Create base directory if not exists
if [ ! -d "$BASEDIR" ]; then
    mkdir -p "$BASEDIR"
fi

# init note file if not exists
if [ ! -f "$FILE" ]; then
    echo "# Notes for $(date -I)" > "$FILE"
fi

vim \
    -c "norm Go" \
    -c "norm Go## $(date +%H:%M)" \
    -c "norm G2o" \
    -c "norm zz" \
    -c "startinsert" \
    "$FILE"
