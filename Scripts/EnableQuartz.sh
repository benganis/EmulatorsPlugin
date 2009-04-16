#!/bin/sh

# Enable Quartz Extreme
defaults write /Library/Preferences/com.apple.windowserver GLCompositor -dict tileHeight -int 256 tileWidth -int 256

# Enable Quartz 2D Extreme
defaults write /Library/Preferences/com.apple.windowserver Quartz2DExtremeEnabled 1

# Kill loginwindow
kill `ps ax | grep loginwindow | grep -v grep | sed -e 's/[[:blank:]]*//' | sed -e 's/[[:blank:]].*//'`