#!/bin/bash

######################   ***********************
# ezrSafeCleaning.sh #  * MAINTAINER kaczkinsky *  #LiveInSafety ;)
######################   ***********************

if [ $USER != "root" ]
then
  echo You must be root to run this program
  exit 1
fi

declare -a logfile="/var/log/ezrSafeCleaning.log"

# We try to know if a /dev/hda or /dev/sda is detected
detect=$(ls -lh /dev/ | grep sda || grep hda)

# Test if detect if true then print on STDOUT
if [[ $detect ]]
then
  echo Hard drive is detected and available to rewrite on
else
  echo Hard drive is not detected
fi

# We define the hard drive as $ddir
#ddir[0]="/dev/sda*"; ddir[1]="/dev/hda*"
ddir[0]="/home/kaczkinski/TEST/testfile"; ddir[1]="~/TEST/testfile"
#echo ${ddir[0]} ${ddir[1]} # to use in debug

# We ask which data we want to be delete
read -p "Inquire partition will be deleting : " part
part="$part"
if [ "${ddir[0]}" == "$part" ] || [ "${ddir[1]}" == "$part" ]
#if true
then
  read -p "Confirm rewriting on disk ? [y/n] : " val
  y="y"
  if [ "$val" == "$y" ]
  then
    # Exec shred rewriting random numbers and erase /dev/sdX
    # Do a redirection from STDERR to STDOUT then the output of shred -v 
    # is duplicate to /var/log/ezrSafeCleaning.log
    shred -vfz --random-source=/dev/urandom -n 70 -u $part 2>&1 | tee -a $logfile
    # // X[$part] O[file_which_contains_absolute_filenames]
    echo "EXIT program"
    echo status ':' SUCCESS
  else
    echo "EXIT program"
    echo status ':' DOWN
  fi
  echo OK
  exit 0
else
  echo NOK
  exit 1
fi
