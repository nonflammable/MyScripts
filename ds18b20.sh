#!/bin/bash

echo "
# ===============================================
#
# Program sprawdza temperaturę z czujnika DS18B20 bez używania dodatkowych skryptów w innych językach programowania (Python or C)
#
# Przykład użycia:
#	./ds18b20.sh [ARGUMENT]
#		Lista argumentów:
#			* -s1 / --save_txt					- zapisuje wartość temperatury do pliku TXT
#			* -s2 / --save_csv					- zapisuje wartość temperatury do pliku CSV
#			* -q / --quiet						- skrypt działa, bez wyświetlania wyników temperatury
#			* -c / --count						- wyświetla ile jest dostępnych czujników
#			* -d [CHAR] / --delimiter_c	[CHAR]	- ustawia [CHAR] jako separator liczb dziesiętnych
#			* -p [STRING] / --prefix [STRING]	- ustawia [STRING] jako prefix plików TXT oraz CSV
#												  Musi zostać użyty przed -s1 oraz -s2
#
#
# ===============================================
#
# Autor: Jarosław Zjawiński Kontakt: code@zjawinski.com.pl WWW: athro.it / zjawinski.com.pl / rainax.pl
# Version: 1.4 (2017-03-14)
#
# ===============================================
" >> /dev/null

START_FOLDER=$(pwd)
RUN_DATE=$(date +'%Y-%m-%d %H:%M:%S')
RUN_DATE_SEC=$(date +'%s')
FILENAME_PREFIX="temperature_"
ILE_CZUJNIKOW=$(ls /sys/bus/w1/devices -l | grep 28 | wc -l)
SAVE_CSV=0
SAVE_TXT=0
PRINT_OUT=1
DELIMITER=.

cd /sys/bus/w1/devices/

TYMCZASOWA_1=0
for file in 28*; do
	NAZWY_PLIKOW[TYMCZASOWA_1]=$file
	TYMCZASOWA_1=$((TYMCZASOWA_1+1))
done

while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-s1|--save_txt)
		FILENAME_TXT=$START_FOLDER/$FILENAME_PREFIX$RUN_DATE_SEC.txt
		echo -e "DATA\t\t\t${NAZWY_PLIKOW[@]}" | tr " " "\t" >> $FILENAME_TXT
		SAVE_TXT=1
		echo "Utworzono plik TXT: $FILENAME_TXT"
		;;
		
		-s2|--save_csv)
		FILENAME_CSV=$START_FOLDER/$FILENAME_PREFIX$RUN_DATE_SEC.csv
		echo "DATA;${NAZWY_PLIKOW[@]}" | tr " " ";" >> $FILENAME_CSV
		SAVE_CSV=1
		echo "Utworzono plik CSV: $FILENAME_CSV"
		;;
		
		-c|--count)
		echo "Znaleziono $ILE_CZUJNIKOW czujników temperatury DS18B20"
		;;
		
		-d|--delimiter)
		DELIMITER=$2
		echo "Ustawiono separator liczb na $DELIMITER"
		;;
		
		-p|--prefix)
		FILENAME_PREFIX=$2
		echo "Ustawiono prefix plików TXT i CSV $FILENAME_PREFIX"
		;;
		
		-d2|--delimiter_d)
		DELIMITER=.
		;;
		
		-q|--quiet)
		echo "Nie będą prezentowane wyniki. Skrypt działa"
		echo "                                           Prawdopodobnie."
		PRINT_OUT=0
		;;
	esac
	shift
done

while (sleep 1); do

	OBECNA_DATA=$(date +'%Y-%m-%d_%H:%M:%S')

	CZUJNIK=0
	for file in 28*; do	
		temp[CZUJNIK]=$( cat $file/w1_slave | grep "t" | cut -d "=" -f2)
		temp[CZUJNIK]=${temp[CZUJNIK]::-3}$DELIMITER${temp[CZUJNIK]:$((${#temp[CZUJNIK]}-3))}
		CZUJNIK=$((CZUJNIK+1))
	done
	
	if [ $SAVE_TXT -eq 1 ]; then
		echo -e "$OBECNA_DATA\t${temp[@]}" | tr " " "\t" >> $FILENAME_TXT
	fi	
	if [ $SAVE_CSV -eq 1 ]; then
		echo "$OBECNA_DATA;${temp[@]}" | tr " " ";" >> $FILENAME_CSV
	fi
	if [ $PRINT_OUT -eq 1 ]; then
		echo -e "$OBECNA_DATA \t ${temp[@]}"
	else
		echo -n "."
	fi
done 
