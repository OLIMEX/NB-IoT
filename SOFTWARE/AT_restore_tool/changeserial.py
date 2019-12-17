#!/usr/bin/env python2

# BC66 repair tool
# Copyright (C) 2019  OLIMEX

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


import serial
import sys

max_tries = 5

def sendAT(cmd):
	command = cmd + "\n\r"
	tried=0
	BREAK = 0
	while (tried < max_tries) and BREAK == 0:
		com.write(bytes(command))
		for i in range(3):
			data = com.readline()
			if "OK" in data:			
				BREAK=1
				break
		tried+=1
	if  BREAK == 1:
		return True
	else:
		return False
	

def checkSN():
	data = ""
	for i in range(3):
		com.write(bytes("AT+CGSN=0\n"))
		for i in range(3):
			data = com.readline()
			if data not in ["OK", "ERROR", "", "ok", "error", " "] :
				break
	if SN not in data:
		return True
	else:
		return False
def checkIMEI():
	data = ""
	for i in range(3):
		com.write(bytes("AT+CGSN=1\n"))
		for i in range(3):
			data = str(com.readline())
			if data not in ["OK", "ERROR", "", "ok", "error", " "] :
				break
	if IMEI not in data:
		return True
	else:
		return False

if (len(sys.argv)) < 4 or "--help" in sys.argv:
	print("\033[36mUsage: python changeserial.py <SN> <IMEI> <SerialPort>\033[0m")
	print("")
	sys.exit(1)

PORT = sys.argv[1]
SN = sys.argv[2]
IMEI = str(sys.argv[3])


if "MPA" not in SN or len(SN) != 15:
	print("\033[31m Wrong SN number\033[0m")
	sys.exit(1)

if len(IMEI) != 15:
	print("\033[31m Wrong IMEI number\033[0m")
	sys.exit(1)



sys.stdout.write("\n")
sys.stdout.write("Openning \""+ PORT + "\"" + "............")
sys.stdout.flush()

try:
	com = serial.Serial(PORT, baudrate=115200, timeout=0.4)
except:
	sys.stdout.write("\033[31m[ FAILED ] \033[0m\n")
	sys.stdout.write("\033[31mThe board is not connected OR wrong Serial Port\033[0m")
	sys.stdout.flush()
	exit(1)

''' Check if board responds to "AT" '''

if not sendAT("AT"):
	sys.stdout.write("\033[31m[ FAILED ] \033[0m\n")
	print("\033[31m Board doesn't answer\033[0m")	
	sys.exit(1)
else:
	sys.stdout.write("\033[32m[ SUCCESS ] \033[0m\n")


AT_LIST = ["AT+CFUN=0", "AT*MNVMQ=\"1.0\"", str("AT*MCGSN=0,\"" + SN + "\""), str("AT*MCGSN=1,\"" + IMEI + "\"")]


''' Change SN and IMEI numbers '''
for cmd in AT_LIST:
	if sendAT(cmd) == False:
		print("\033[31mCouldn't send {}\033[0m".format(cmd))
		sys.exit(1)
	

''' Reset the board '''
if not sendAT("AT+QRST=1"):
	print("\033[31mCouldn't send {}\033[0m".format("AT+QRST=1"))
	sys.exit(1)

''' Baudrate sync '''
if not sendAT("AT"):
	print("\033[31mCouldn't send {}\033[0m".format("AT"))
	sys.exit(1)

''' Check if SN and IMEI are changed '''

if (checkSN() and checkIMEI()):
	print("\033[32m============== BOARD RESTORED SUCCESSFULLY!!! ============== \033[0m")
else:
	print("\033[31m============== BOARD RESTORED UNSUCCESSFULLY!!! ============== \033[0m")
