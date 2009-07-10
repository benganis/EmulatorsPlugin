#!/bin/sh

#  $Author$
#  $Date$
#  $Rev$
#  $HeadURL$

password=frontrow
echo $password | sudo -S touch /private/var/db/.AccessibilityAPIEnabled
