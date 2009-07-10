#!/bin/sh

#  $Author$
#  $Date$
#  $Rev$
#  $HeadURL$

# Enable Quartz Extreme
defaults write /Library/Preferences/com.apple.windowserver GLCompositor -dict tileHeight -int 256 tileWidth -int 256

# Enable Quartz 2D Extreme
defaults write /Library/Preferences/com.apple.windowserver Quartz2DExtremeEnabled 1
