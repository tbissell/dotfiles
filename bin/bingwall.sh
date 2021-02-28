#!/bin/bash

# Setup stuff
BING="http://www.bing.com"
API="/HPImageArchive.aspx?"
FORMAT="&format=js"
# For day. 0 for today; 1 for yesterday; etc
DAY="&idx=0"
MARKET="&mkt=en-US"
# How many to fetch
CONST="&n=1"
EXTN=".jpg"
SIZE="1920x1080"

SAVEPATH="$HOME/backgrounds/"

# Assemble URI
REQ="$BING$API$FORMAT$DAY$MARKET$CONST"

echo "$REQ"

# Test ping the API
API=$(curl -s "$REQ")
if [ $? -gt 1 ]; then
    echo "Ping failed!"
    exit 1
fi

#DEFAULT_URL="$BING$(echo $API | jq -r '.images[0].url')"
RAW_URL="$BING$(echo "$API" | jq -r '.images[0].urlbase')_$SIZE$EXTN"
COPYRIGHT="$(echo "$API" | jq -r '.images[0].copyright')"

# echo "DEFAULT: $DEFAULT_URL"
# echo "RAW: $RAW_URL"
# echo "COPYRIGHT: $COPYRIGHT"

echo "Image of the day: $RAW_URL"

mkdir -p "$SAVEPATH"
IMG_NAME=$(echo "$RAW_URL" | sed -re 's,.*id=(.*),\1,')

FILENAME="$SAVEPATH$IMG_NAME"
curl -L -s -o "$FILENAME" "$RAW_URL"

echo "Copyright: $COPYRIGHT"
nitrogen --head=0 --set-auto "$FILENAME"
