#!/bin/bash

IPDOMOTICZ='localhost'
PORTDOMOTICZ=8080
DS18B20="28-80000003f7a7"
IDX=4
WAIT=10

URL="http://$IPDOMOTICZ:$PORTDOMOTICZ/json.htm?type=command&param=udevice&idx=$IDX&nvalue=0&svalue="

DIRECTORY="/tmp/$(date +'%s')/$DS18B20"
mkdir -p $DIRECTORY
cd $DIRECTORY

while (sleep $WAIT); do
	cp "/sys/bus/w1/devices/$DS18B20/w1_slave" "$DIRECTORY/czujnik"
		if (cat czujnik | grep "YES"); then
			temp=$( cat czujnik | grep "t" | cut -d "=" -f2)
			temp=${temp::-3}.${temp:$((${#temp}-3))}

			curl "$URL$temp"
		fi
	rm -f czujnik
done


#EoF
#Enclude; 
#2017-03-21
