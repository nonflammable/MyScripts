#!/bin/bash

IPDOMOTICZ='localhost'
PORTDOMOTICZ=8080
CZUJNIK="28-80000003f7a7"
IDX=4
CZAS=10

URL="http://$IPDOMOTICZ:$PORTDOMOTICZ/json.htm?type=command&param=udevice&idx=$IDX&nvalue=0&svalue="

KATALOG="/tmp/$(date +'%s')/$CZUJNIK"
mkdir -p $KATALOG
cd $KATALOG

while (sleep $CZAS); do
	cp "/sys/bus/w1/devices/$CZUJNIK/w1_slave" "$KATALOG/czujnik"
		if (cat czujnik | grep "YES"); then
			temp=$( cat czujnik | grep "t" | cut -d "=" -f2)
			temp=${temp::-3}.${temp:$((${#temp}-3))}

			echo $temp
			curl "$URL$temp"
		fi
		rm -f czujnik
done


#EoF
#Enclude; 
#2017-03-21