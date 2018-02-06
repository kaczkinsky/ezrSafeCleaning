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
os=$(uname -a)
set -- $os
echo "Operating System :" $6

# Try to detect coreutils pkg
# If coreutils pkg is missing, installation of latest coreutils release for available os
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

# Clone coreutils repository (contains shred pkg) from github
# coreutils_install=$(git clone https://github.com/wertarbyte/coreutils.git)
# exec $coreutils_install

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
