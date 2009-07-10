#!/bin/sh

#  $Author$
#  $Date$
#  $Rev$
#  $HeadURL$

kill $(ps ax | grep [F]inder | awk '!/KillFinder/ {print $1}')
