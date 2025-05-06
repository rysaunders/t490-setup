#!/bin/bash

# Kill existing bars
killall -q polybar

# Wait until they’re gone
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar
polybar example &
