#!/bin/bash

# BC66 repair tool
#Copyright (C) 2019  OLIMEX

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.


#Disable ModemManager
sudo systemctl disable ModemManager.service > /dev/null 2>&1
sudo systemctl stop ModemManager.service > /dev/null 2>&1

REQUIRED_PACKAGES=(git dkms python python-minimal python-serial)
INSTALL_LIST=()
for package in ${REQUIRED_PACKAGES[@]}; do
    dpkg -l | grep -w $package > /dev/null 2>&1 || \
    INSTALL_LIST+=($package)
done

if [[ ! -z $INSTALL_LIST ]];
	then
		echo "=============== Installing ================="
		echo ""
		sudo apt-get update > /dev/null 2>&1
		
		for package in ${INSTALL_LIST[@]}; do
			echo "This script needs to install $package package in order to start successfully"
			echo "Do you want to install $package (Y/N) ?"
			read -n 1 -s key
			[[ $key != 'y' ]] && [[ $key != 'Y' ]] && continue
			echo -n "Installing $package.................."
			sudo apt-get install -y $package > /dev/null 2>&1 && \
			echo -e "$GREEN[DONE]$RESET" || echo -e "$RED[FAILED]$RESET" && echo "Failed to install $package" >> ./Installation.LOG
		done

fi


#------------------ Variables definitions ---------------------->
GREEN="\033[32m"
RED="\033[31m"
CYAN="\033[36m"

BOLD="\033[1m"
RESET="\033[0m"

DONE="$GREEN[ DONE ]$RESET"
FAILED="$RED[ FAILED ]$RESET"
SKIP="$CYAN[ SKIPPED ] $RESET"

FLASHTOOL_DIR="./IoT_Flashtool_Linux"
FLASHTOOL="python $FLASHTOOL_DIR/MT2625.py"

#------------------ Function definitions  ---------------------->

function bold()
{
	echo -ne "$BOLD$1$RESET"
}

function printline()
{
	echo -e $1
}

function find_ch340()
{
        VID="1a86"
        PID="7523"

        PORT=""
        for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev)
        do
                        syspath="${sysdevpath%/dev}"
                        devname=$(udevadm info -q name -p $syspath)
                        [[ $devname == *"bus/"* ]] && continue || \
                        [[ $(udevadm info -q all -p $syspath | grep ID_VENDOR_ID) == *"$VID"* && $(udevadm info -q all -p $syspath | grep ID_MODEL_ID) == *"$PID"* ]] && PORT="$devname" && break
        done

        [[ ! -z  $PORT ]] && PORT=($echo "/dev/$PORT")

}

function erase_app()
{
	find_ch340
	
	while true;
	do
		echo -n "Removing app......................."
		read -n 1 -t 3 -s && echo -e $SKIP && break
		$FLASHTOOL $PORT 0x08292000 $FLASHTOOL_DIR/eraseapp.bin > ./ERASE.log 2>&1 && printline "$DONE" && break
		printline ""$FAILED""
		echo ""
		echo "$(bold ENTER) - retry $(bold ESC) - cancel"
	done

}

function restore_nvdm()
{
	find_ch340

		while true;
	do
		
		echo -n "Restoring nvdm....................."
		read -n 1 -t 3 -s && echo -e $SKIP && break
		$FLASHTOOL $PORT 0x083A5000 $FLASHTOOL_DIR/restore.bin > ./RESTORE.log 2>&1 && printline "$DONE" && break
		printline ""$FAILED""
		echo ""
		echo "$(bold ENTER) - retry $(bold ESC) - cancel"
	done
}

function change_imei()
{
	find_ch340
	python ./changeserial.py $PORT $SN $IMEI

}

#------------------    Main function     ----------------------->

if [[ $1 != *"MPA"* || $(expr length $1) != 15 ]];
	then
		printline "$RED Wrong SN number$RESET "
		exit 1
fi

if [[ $(expr length $2) != 15 ]];
	then
		printline "$RED Wrong IMEI number $RESET"
		exit 1
fi

SN=$1
IMEI=$2

printline "$CYAN====================== BEGIN REPAIRING =====================$RESET"

erase_app
restore_nvdm
change_imei

