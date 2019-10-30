With this tool you can flash your bc66 board
or backup/restore youre NVDM

Requirements:
	python
	python-serial module installed

How to use it:

1. Backup NVDM:

	#This will create <imei>.dat file. 

	python ./MT2625.py <serial_port> --backup.


2. Flash firmware:

	#Upload Bootloader:
	python ./MT2625.py <serial_port> 0x08002000 <bootloader.bin>
	
	#Upload Firmware:
	python ./MT2625.py <serial_port> 0x08012000 <firmware.bin>
	
3. Upload application:
	
	python ./MT2625.py <serial_port> 0x08292000 <application.bin>

4. Erase application:

	python ./MT2625.py <serial_port> 0x08292000 ./eraseapp.bin

5. Restore NVDM:

	python ./MT2625.py <serial_port> 0x083A5000 <imei>.dat

6. Simultaneously Backup + one of the options above:

	python ./MT2625.py \<serial_port\> \<address\> \<file\> --backup

       	i.e: Backup + upload:

	python ./MT2625.py <serial_port> 0x08292000 <application.bin> --backup

