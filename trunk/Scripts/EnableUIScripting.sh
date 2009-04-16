#!/bin/sh

password=frontrow
echo $password | sudo -S touch /private/var/db/.AccessibilityAPIEnabled
