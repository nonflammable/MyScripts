#!/bin/bash

# ===============================================
#
# Program sprawdza jakie IP są w sieci lokalnej na podstawie zadanego parametru
# Program zwraca dwa pliki TXT oraz CSV (oddzielony średnikami)
#
#
# Autor: Jarosław Zjawiński
# Kontakt: jaroslaw.zjawinski@athro.it
# WWW: athro.it / zjawinski.com.pl / rainax.pl
#
# ===============================================



clear

NAZWA_SKRYPTU=$(date +%s)

mkdir /tmp/$NAZWA_SKRYPTU
mkdir /tmp/$NAZWA_SKRYPTU/split/
PLIK1=/tmp/$NAZWA_SKRYPTU/001.txt
PLIK2=/tmp/$NAZWA_SKRYPTU/002.txt
PLIK3=/tmp/$NAZWA_SKRYPTU/003.txt

echo "Podaj IP/zakres/maske do sprawdzenia"
read IP_SCAN

echo "Sprawdzam: $IP_SCAN"

nmap -sn $IP_SCAN >> $PLIK1
tail -n +3 $PLIK1 >> $PLIK2
head -n -1 $PLIK2 >> $PLIK3
split -l 3 $PLIK3 /tmp/$NAZWA_SKRYPTU/split/SKRYPT_

for file in /tmp/$NAZWA_SKRYPTU/split/*; do
        while IFS= read -r line; do

	if (echo $line | grep 'report' > /dev/null); then
               IP=${line:21}
        fi
        if (echo $line | grep 'MAC' > /dev/null); then
                MAC=${line:13:17}

                PRODUCENT_NMAP=$(echo $line | grep "MAC" |cut -d "(" -f2 | cut -d ")" -f1)

                echo -e "|| $IP || $MAC || $PRODUCENT_NMAP || $(date +'%Y-%m-%d %H:%M:%S')" >> wynik_$NAZWA_SKRYPTU.txt
                echo "$IP;$MAC;$PRODUCENT_NMAP;$(date +'%Y-%m-%d %H:%M:%s')" >> wynik_$NAZWA_SKRYPTU.csv
        fi

        done < $file
        echo -e "\n"
done

ILE_IP=$(tail -n -1 $PLIK1 | cut -d "(" -f2 | cut -d " " -f1)

clear
echo -e "GOTOWE! \n    Sprawdzano zakres: $IP_SCAN (Dostepne IP: $ILE_IP)"
echo "Plik CSV: $(pwd)/wynik_$wynik_$NAZWA_SKRYPTU.csv"
echo "Plik TXT: $(pwd)/wynik_$wynik_$NAZWA_SKRYPTU.txt"

rm -rf /tmp/$NAZWA_SKRYPTU
