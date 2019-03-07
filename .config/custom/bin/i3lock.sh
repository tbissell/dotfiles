#!/usr/bin/env bash

# Requires i3lock and imagemagick at a minimum. Scrot will be used
# if available.

CMD_PATH="$(dirname "$(readlink -f "$0")")"

IMAGE="$CMD_PATH/../var/lock.png"

if [ -x "$(command -v scrot)" ]; then
    # use scrot if available, *much* faster
    scrot "$IMAGE"
else
    import -window root -delay 0 "$IMAGE"
fi

# Blur the image
convert "$IMAGE" -blur 0x4 "$IMAGE"

# Do the lock
i3lock -i "$IMAGE"

