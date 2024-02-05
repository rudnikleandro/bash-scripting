#!/bin/bash

# Decrease screen brightness to 50%
xrandr --output eDP-1 --brightness 0.5

# Power off Bluetooth
rfkill block bluetooth

# Power off wireless
rfkill block wifi

echo "Screen brightness decreased and  Bluetooth and Wireless turned off to save battery"
