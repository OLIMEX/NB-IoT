This is AT restore firmware procedure for Olimex NB-IoT-Devkit

It should be used if you overwrote the AT command firmware. It is made for Linux.

####################################################

Preparation:

Download all files from the folder where this README is located. 

In order to install a patched CH340 driver, please run "install_ch340.sh" file:

1. Open terminal in the directory containing "install_ch340.sh".
2. Execute the following line:

  ./install_ch340.sh

The reason is that this script allows CH340T to operate at higher baudrate and enables auto-reset 
function, which is not supported with the official ch340 drivers for Linux.

If you have trouble with the shell script, you can also find the driver here:
https://github.com/OLIMEX/ch340-dkms

If you update the kernel of your Linux installation, you might need to run the installation again!

####################################################

Once the driver is successfully installed:

1. Connect Olimex NB-IoT-Devkit board to your PC

2. Open new terminal in the current directory

3. Enter down:
 ./REPAIR.SH <SN> <IMEI>

where SN and IMEI are written on the top of Qeuctel BC66 IC. 

Notice that the repair script uses auto-detect, so make sure you have only one peripheral using
CH340 convertor for the USB connection.

####################################################
