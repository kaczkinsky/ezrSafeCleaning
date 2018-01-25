#!/bin/bash

######################  *******************
# erzSafeCleaning.sh #  * FROM kaczkinski * :) #LiveInSafety
######################  *******************

if [ $USER != "root" ]
then
  echo You must be root to run this program
  exit 1
fi

declare -a logfile="/var/log/erzSafeCleaning.log"

# We try to know if a /dev/hda or /dev/sda is detected
detect=$(ls -lh /dev/ | grep sda || grep hda)
# $detect is available in verbose mode
if [[ $detect ]]
then
  echo Hard drive is detected and available to rewrite on
else
  echo Hard drive is not detected
fi

# We initialize a hard drive as a $var
ddir[0]="/dev/sda"; ddir[1]="/dev/sdb"
echo ${ddir[0]} ${ddir[1]}

# We ask which data we want to be delete
read -p "Inquire partition will be deleting : " part
part="$part"
if [ "${ddir[0]}" == "$part" || "${ddir[1]}" == "$part" ]
#if true
then
  read -p "Confirm rewriting on disk ? y or n : " val
  y="y"
  if [ "$val" == "$y" ]
  then
    # Exec shred deletion and redirect logs of verbose mode then print on stdout
    exec shred -v -n 70 --force --remove -z $part | tee -a $logfile # the redirection of shred cmd is not effective yet 
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
