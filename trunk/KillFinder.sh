#!/bin/sh

kill $(ps ax | grep [F]inder | awk '!/KillFinder/ {print $1}')
