#!/bin/sh

#  $Author$
#  $Date$
#  $Rev$
#  $HeadURL$

dirname=$1
emuname=$2
romname=$3

function receive_signal {
  echo "Received signal"
  echo "Killing" $emuname
  killall "$emuname"
  if [ "$emuname" = "zsnes" ]; then
    killall "ZSNES"
  fi
  exit 0
}
trap receive_signal SIGHUP SIGINT SIGTERM

function runcmd {
   CMD="$1"
   echo $CMD
   $CMD
   if [ $? -ne 0 ]; then
      echo "Error - exiting RunScript.sh!"
      exit 1;
   fi
}

function runcmd_args {
   CMD="$1"
   ARGS="$2"
   echo $CMD $ARGS
   $CMD $ARGS
   if [ $? -ne 0 ]; then
      echo "Error - exiting RunScript.sh!"
      exit 1;
   fi
}

if [ -z $1 ] || [ -z $2 ]; then
  echo "Usage: rungame [Dir Name] [Script Name] [Arguments]"
  exit 1
elif ! [ -d $dirname ]; then
  echo "Error: Directory $dirname not found"
  exit 1
fi

runcmd "cd $dirname"

if ! [ -f $emuname ]; then
  echo "Error: File $emuname not found"
  exit 1
fi

runcmd_args "./$emuname" "$romname"

### Get PID of Emulator ###
emupid=`ps auxww | grep "$emuname" | awk '!/grep/ && !/rungame/ {print $2}'`
if [[ -z $emupid ]]; then
  echo "Error:" $emuname "failed to launch!"
  exit 2
fi

echo "Staying open for PID" $emupid "..."
#wait $emupid

### Keep alive until Emulator's PID Disappears ###
until [ -z $emupid ]; do
   sleep 1
   emupid=`ps auxww | grep "$emuname" | awk '!/grep/ && !/rungame/ {print $2}'`
done
echo $emuname "exited"
