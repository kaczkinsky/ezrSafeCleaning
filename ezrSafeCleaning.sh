#!/bin/bash

if [ $USER != "root" ]
then
  echo You must be root to run this program
  exit 1
fi

declare -a logfile="/var/log/ezrSafeCleaning.log"
os=$(uname -a)
set -- $os
echo "Operating System :" $6

# Try to detect coreutils pkg (contains shred.c)
# If coreutils pkg is missing, run installation of latest coreutils release for available os
coreutils_detect=$(sudo find / -iname "coreutils" 2>/dev/null)

if [[ $coreutils_detect ]]
then
  echo "Coreutils and its dependencies can be used on this OS"
else
  $6="$6"
  if "$6" == "Debian"
    then apt-get update; apt-get install -y coreutils
  elif "$6" == "Fedora"
    then yum install coreutils || dnf install coreutils
  elif "$6" == "Gentoo"
    then emerge --ask --verbose dev-vcs/coreutils
  elif "$6" == "Arch Linux"
    then pacman -S coreutils
  elif "$6" == "openSUSE"
    then zypper install coreutils
  elif "$6" == "Free BSD"
    then pkg install coreutils
  elif "$6" == "Open BSD"
    then pkg_add coreutils
  elif "$6" == "Alpine"
    then apk add coreutils
  elif "$6" == "Tiny Core"
    then tce-load -wi coreutils.tcz
  fi
fi

# We try to know if a /dev/hda or /dev/sda is detected
detect=$(ls -lh /dev/ | grep sda || grep hda)

# Test if detect if true then print on STDOUT
if [[ $detect ]]
then
  echo Hard drive is detected and available to rewrite on
else
  echo Hard drive is not detected
fi

# The following instructions are use to debug or test
# Comments them to run properly the program on a hard drive
touch /tmp/file.test
ddir[0]="/tmp/file.test"; ddir[1]="/tmp/file.test"

# We define the hard drive as $ddir
# Uncomment the following line to run properly the program
#ddir[0]="/dev/sda"; ddir[1]="/dev/hda"

# We ask which data we want to be delete
read -p "Inquire partition will be deleting : " part
part="$part"
if [ "${ddir[0]}" == "$part" ] || [ "${ddir[1]}" == "$part" ]
#if true # to use in debug or test
then
  read -p "Confirm rewriting on disk ? [y/n] : " val
  y="y"
  if [ "$val" == "$y" ]
  then
    # Exec shred rewriting random numbers and erase /dev/sdX
    # Do a redirection from STDERR to STDOUT
    # The output of shred -v is duplicate to /var/log/ezrSafeCleaning.log
    shred -vfz --random-source=/dev/urandom -n 8 -u $part 2>&1 | tee -a $logfile
    echo status ':' SUCCESS
    echo "EXIT program"
  else
    echo status ':' DOWN
    echo "EXIT program"
    exit 2
  fi
  exit 1
else
  exit 2
fi
