#!/bin/sh

USERNAME="XXX"
PASSWORD="XXX"
SERVER="gmail.com"


sleep 25;

echo "67" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio67/direction
echo "0" > /sys/class/leds/blue_led/brightness

echo '||===== '$(date +%F' '%H:%M:%S)' ======' >> powiadomienie.txt
echo $(date +%F' '%H:%M:%S) >> /var/log/gpio/gpio67/start.log
echo '|| POWIADOMIENIE: Uruchomienie systemu' >> powiadomienie.txt
echo '|| ADRESS IP: '$(hostname -I) >> powiadomienie.txt
echo '||=========================================' >> powiadomienie.txt
cat powiadomienie.txt | sendxmpp -t -u $USERNAME -o $SERVER $PASSWORD
rm powiadomienie.txt

while sleep 1; do
        clear
        if cat /sys/class/gpio/gpio67/value | grep 1; then
                echo "1" > /sys/class/leds/blue_led/brightness

                data=$(date +%F' '%H:%M:%S)

		echo '||===== '$data' ======' >> powiadomienie.txt
		echo '|| POWIADOMIENIE: Otwarcie szafy serwerowej' >> powiadomienie.txt
		echo '|| URZĄDZENIE: NanoPi (#001)' >> powiadomienie.txt
		echo '|| ADRESS IP: '$(hostname -I) >> powiadomienie.txt
		echo '||' >> powiadomienie.txt
		echo '|| KLIENT: (-----------) XYZ' >> powiadomienie.txt
		echo '||          XYZ' >> powiadomienie.txt
		echo '|| KONTAKT: AAA BBB +48 111 222 333' >> powiadomienie.txt
                echo '||=========================================' >> powiadomienie.txt

                echo $data >> /var/log/gpio/gpio67/szafa.log
                cat powiadomienie.txt | sendxmpp -t -u jaroslaw.zjawinski.3 -o gmail.com jaroslaw.zjawinski@gmail.com
		rm powiadomienie.txt
                echo "0" > /sys/class/leds/blue_led/brightness

		while cat /sys/class/gpio/gpio67/value | grep 1; do
			sleep 1
		done
        fi
done
