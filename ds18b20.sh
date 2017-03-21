#!/bin/bash

START_FOLDER=$(pwd)
RUN_DATE=$(date +'%Y-%m-%d %H:%M:%S')
RUN_DATE_SEC=$(date +'%s')
FILENAME_PREFIX="temperature_"
HOWMANYDS18B20=$(ls /sys/bus/w1/devices -l | grep 28 | wc -l)
SAVE_CSV=0
SAVE_TXT=0
PRINT_OUT=1
DELIMITER=.

show_help () {
	echo "
Script check temperature from all founded sensor. No more tools requied. 

Example of use:
./ds18b20.sh

You can use of parameters, list bellow. 
-s1 or --save_txt	- save output to TXT file
-s2 or --save_csv	- save output to CSV file
-q  or --quiet		- script working, but no output visible
-c	or --count		- script show how many DS18B20 founded
-d [CHAR] or --delimiter_c [CHAR]	- set decimal separator to [CHAR]
-p [STRING] or --prefix [STRING]	- set TXT and CSV prefix to [STRING]

Author:
	Jarosław Zjawiński (code@zjawinski.com.pl)
	WWW: athro.it / zjawinski.com.pl / rainax.pl
	
Version:
	v1.6 (2017-03-21)
"
	exit
}

# Script check serial number of DS18B20 and save to array
cd /sys/bus/w1/devices/
TEMPORARY_1=0
for file in 28*; do
	ID_DS18B20[TEMPORARY_1]=$file
	TEMPORARY_1=$((TEMPORARY_1+1))
done

while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-s1|--save_txt)
		SAVE_TXT=1
		;;

		-s2|--save_csv)
		SAVE_CSV=1
		;;
		
		-p|--prefix)
		FILENAME_PREFIX=$2
		echo "Set TXT and CSV prefix file to: $FILENAME_PREFIX"
		;;
		
		-c|--count)
		echo "Find $HOWMANYDS18B20 DS18B20 temperature sensor(s)."
		;;
		
		-h|--help)
		show_help
		;;
		
		-d|--delimiter)
		DELIMITER=$2
		echo "Set decimal separator to: $DELIMITER"
		;;
		
		-q|--quiet)
		PRINT_OUT=0
		echo "Output will not present. Script working. "
		;;
	esac
	shift
done

if [ $SAVE_TXT -eq 1 ]; then
	FILENAME_TXT=$START_FOLDER/$FILENAME_PREFIX$RUN_DATE_SEC.txt
	echo -e "DATE\t\t\t${ID_DS18B20[@]}" | tr " " "\t" >> $FILENAME_TXT
	echo "Created TXT file: $FILENAME_TXT"
fi	
if [ $SAVE_CSV -eq 1 ]; then
	FILENAME_CSV=$START_FOLDER/$FILENAME_PREFIX$RUN_DATE_SEC.csv
	echo "DATE;${ID_DS18B20[@]}" | tr " " ";" >> $FILENAME_CSV
	echo "Created CSV file: $FILENAME_CSV"
fi

while (sleep 1); do

	NOWDATE=$(date +'%Y-%m-%d_%H:%M:%S')

	SENSOR=0
	for file in 28*; do	
		temp[SENSOR]=$( cat $file/w1_slave | grep "t" | cut -d "=" -f2)
		temp[SENSOR]=${temp[SENSOR]::-3}$DELIMITER${temp[SENSOR]:$((${#temp[SENSOR]}-3))}
		SENSOR=$((SENSOR+1))
	done
	
	if [ $SAVE_TXT -eq 1 ]; then
		echo -e "$NOWDATE\t${temp[@]}" | tr " " "\t" >> $FILENAME_TXT
	fi	
	if [ $SAVE_CSV -eq 1 ]; then
		echo "$NOWDATE;${temp[@]}" | tr " " ";" >> $FILENAME_CSV
	fi
	if [ $PRINT_OUT -eq 1 ]; then
		echo -e "$NOWDATE \t ${temp[@]}"
	else
		echo -n "."
	fi
done 
