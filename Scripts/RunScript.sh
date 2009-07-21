#!/bin/bash

#  $Author$
#  $Date$
#  $Rev$
#  $HeadURL$

dirname=$1
emuname=$2
romname=$3

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
   echo $CMD $ARGS "&"
   $CMD $ARGS &
}

echo "In RunScript.sh..."
echo "dirname=" $dirname
echo "emuname=" $emuname
echo "romname=" $romname

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then
  echo "Usage: rungame [Dir Name] [Script Name] [Arguments]"
  exit 1
elif ! [[ -d $dirname ]]; then
  echo "Error: Directory $dirname not found"
  exit 1
fi

runcmd "cd $dirname"

if ! [[ -f $emuname ]]; then
  echo "Error: File $emuname not found"
  exit 1
fi

runcmd_args "./$emuname" "$romname"

echo "Done."
exit 0
