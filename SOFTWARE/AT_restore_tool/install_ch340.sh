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

function install_ch340()
{
	# Install ch340-dkms
	echo "You need to install a modified ch340 driver in order to use this script successfully"
	echo -e "\033[1mDo you want to install the modified ch340 driver? Y/N\033[0m"
	read -n 1 -s key
	if [[ $key == 'y' || $key == 'Y' ]]
	then
		[[ ! -d ch340-dkms ]] && git clone --depth=1 https://github.com/OLIMEX/ch340-dkms
		cd ch340-dkms
		# Make sure ch340-dkms is removed
		sudo dkms remove ch340/1.0.0 --all 
		sudo dkms build .
		sudo dkms install ch340/1.0.0 
		cd -
		# Blacklist ch341
		if ! grep -q "blacklist ch341" /etc/modprobe.d/blacklist.conf; then
			echo "blacklist ch341" | sudo tee -a /etc/modprobe.d/blacklist.conf > /dev/null
			sudo systemctl restart systemd-modules-load.service
		fi

		# Make sure ch341 is unloaded
		lsmod | grep -q "ch341" && \
		sudo rmmod ch341
		fi
	
}

function uninstall_ch340()
{
	echo "DKMS ch340 driver needs to be uninstalled first"
	echo -e "\033[1mDo you want to continue? (Y/N)\033[0m"
	read -n 1 -s key 
	echo ""
	if [[ $key == 'y' || $key == 'Y' ]];
	then
		sudo dkms uninstall ch340/1.0.0
	else
		exit
	fi

}



if ! dkms status | grep -q "ch340,.*installed"; then
	install_ch340
else
	uninstall_ch340
	install_ch340
fi

