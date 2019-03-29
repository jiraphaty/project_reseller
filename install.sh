#!/bin/bash

#check root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#check os
os=$(lsb_release -c | grep "Codename:")
version=$(echo $os | sed -e 's/Codename\://g')

if [ $version = "trusty" ]
then
	oscheck="ok"
else
	clear
	echo -e '\n\n'
	echo -e '\t\t#################################################'
	echo -e '\t\t#\t\t\t\t\t\t#'
	echo -e '\t\t#   This script does not support your os.\t#'
	echo -e '\t\t#\t\t\t\t\t\t#'
	echo -e '\t\t#################################################'
	echo -e '\n\n'
	exit 1
fi


clear
apt-get install jq -y >/dev/null 2>&1
webreseller=$(curl -s 'https://raw.githubusercontent.com/jiraphaty/project_reseller/master/host' | jq -r '.host_for_buy')

echo -e '\n\n'
echo -e '\t\t#################################################'
echo -e '\t\t#\t\t\t\t\t\t#'
echo -e '\t\t#    This script made by Jiraphat Yuenying\t#'
echo -e '\t\t#\t\t\t\t\t\t#'
echo -e '\t\t#        You can get key in link below\t\t#'
echo -e '\t\t#\t\t\t\t\t\t#'
echo -e '\t\t#\t   Website  : '$webreseller'\t\t#'
echo -e '\t\t#\t\t\t\t\t\t#'
echo -e '\t\t#################################################'
echo -e '\n\n'

printf '\t\tKey for install : '
read key_i

MYIP=$(wget -qO- ipv4.icanhazip.com);
api_install=$(curl -s 'https://raw.githubusercontent.com/jiraphaty/project_reseller/master/host' | jq -r '.host_for_check_key')
HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --data "key="$key_i"&ip="$MYIP"&install=ok" $api_install)
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

if [ $HTTP_STATUS -eq 200 ]
then
	if [ "$HTTP_BODY" = "ok" ]
	then
		echo -e '\n\n'
		echo -e '\t\t#################################################'
		echo -e '\t\t#\t\t\t\t\t\t#'
		echo -e '\t\t#\t     This key is available\t\t#'
		echo -e '\t\t#\t\t\t\t\t\t#'
		echo -e '\t\t#################################################'
		echo -e '\n'
		printf '\t\tConfirm install (y/n) : '
		read confirm
		if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]
		then
			echo -e '\n'
			echo -e "Confirmed."
			printf 'Set your Database password: '
			read passwordsql
			clear
			echo -e '\n'
			echo -e '\t\t\t  Do not turn off your server.\t\t'
			echo -e '\n'
			
			echo -e '\t\t\t     Server is updating...\t\t'
			
			api_download=$(curl -s 'https://raw.githubusercontent.com/jiraphaty/project_reseller/master/host' | jq -r '.host_for_download')
			api_host=$(curl -s 'https://raw.githubusercontent.com/jiraphaty/project_reseller/master/host' | jq -r '.host')
			
			apt-get update -y > /dev/null
			echo -e 'Server was updated.'
			
			echo -e '\t\t\t     Script is installing...\t\t'
			
			apt-get remove --purge mysql-server php5-mysql -y >/dev/null 2>&1
			apt-get autoremove --purge -y >/dev/null 2>&1
			apt-get autoclean >/dev/null 2>&1
			
			rm -rf /etc/mysql >/dev/null 2>&1
			find / -iname 'mysql*' -exec rm -rf {} \; >/dev/null 2>&1
			
			echo -e 'Reset mysql.'
			timedatectl set-timezone Asia/Bangkok
			
			apt-get update > /dev/null
			echo -e 'Server was updated.'
			
			#install apeche2
			apt-get install apache2 -y >/dev/null 2>&1
			echo -e 'Webserver was installed.'
			
			
			#install mysql
			export DEBIAN_FRONTEND=noninteractive >/dev/null 2>&1
			apt-get install mysql-server php5-mysql -q -y >/dev/null 2>&1
			mysqladmin -u root password $passwordsql >/dev/null 2>&1
			
			#install php
			apt-get install php5 libapache2-mod-php5 php5-mcrypt php5-curl -y >/dev/null 2>&1
			service apache2 restart >/dev/null 2>&1
			
			echo -e 'Website config is installing...'
			#set index.php as default
			
			temp_link=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --data "service=apache2&file=dir.conf" $api_download)
			download_link=$(echo $temp_link | sed -e 's/HTTPSTATUS\:.*//g')
			
			#wget -O /etc/apache2/mods-enabled/dir.conf 'https://raw.githubusercontent.com/jiraphaty/auto-script-vpn/master/openvpnweb/dir.conf' >/dev/null 2>&1
			wget -O /etc/apache2/mods-enabled/dir.conf $download_link >/dev/null 2>&1

			#enable mod_rewrite
			sudo a2enmod rewrite >/dev/null 2>&1
			service apache2 restart >/dev/null 2>&1
			
			temp_link=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --data "service=apache2&file=apache2.conf" $api_download)
			download_link=$(echo $temp_link | sed -e 's/HTTPSTATUS\:.*//g')
			
			#wget -O /etc/apache2/apache2.conf 'https://raw.githubusercontent.com/jiraphaty/project_reseller/master/apache2.conf' >/dev/null 2>&1
			wget -O /etc/apache2/apache2.conf $download_link >/dev/null 2>&1
			
			temp_link=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --data "service=apache2&file=000-default.conf" $api_download)
			download_link=$(echo $temp_link | sed -e 's/HTTPSTATUS\:.*//g')
			#wget -O /etc/apache2/sites-available/000-default.conf 'https://raw.githubusercontent.com/jiraphaty/project_reseller/master/000-default.conf' >/dev/null 2>&1
			wget -O /etc/apache2/sites-available/000-default.conf $download_link >/dev/null 2>&1
			service apache2 restart >/dev/null 2>&1
			
			cd /home >/dev/null 2>&1
			rm -rf webserver >/dev/null 2>&1
			mkdir webserver >/dev/null 2>&1
			cd webserver >/dev/null 2>&1
			mkdir html >/dev/null 2>&1
			cd
			
			temp_link=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --data "service=html&file=htdocs_openvpn_final.tar" $api_download)
			download_link=$(echo $temp_link | sed -e 's/HTTPSTATUS\:.*//g')
			#wget -O /home/webserver/html/htdocs.tar 'https://github.com/jiraphaty/auto-script-vpn/raw/master/openvpnweb/htdocs_openvpn_final.tar' >/dev/null 2>&1
			wget -O /home/webserver/html/htdocs.tar $download_link >/dev/null 2>&1
			cd /home/webserver/html >/dev/null 2>&1
			tar xf htdocs.tar >/dev/null 2>&1
			rm htdocs.tar >/dev/null 2>&1
			echo -e 'Website was installed.'
			
			#install openvpn

			apt-get purge openvpn easy-rsa -y >/dev/null 2>&1; 
			apt-get purge squid3 -y >/dev/null 2>&1;
			
			MYIP2="s/xxxxxxxxx/$MYIP/g" >/dev/null 2>&1;
			
			apt-get update >/dev/null 2>&1
			echo -e 'Server was updated.'
			
			apt-get install bc -y >/dev/null 2>&1
			apt-get -y install openvpn easy-rsa >/dev/null 2>&1;
			apt-get -y install python >/dev/null 2>&1;
			echo -e 'Openvpn was installed.'
			
			#wget -O /etc/openvpn/openvpn.tar "https://raw.githubusercontent.com/jiraphaty/auto-script-vpn/master/openvpn.tar" >/dev/null 2>&1
			#wget -O /etc/openvpn/default.tar "https://raw.githubusercontent.com/jiraphaty/auto-script-vpn/master/default.tar" >/dev/null 2>&1
			wget -O /etc/openvpn/openvpn.tar $api_host"/asset_script/openvpn/openvpn.tar" >/dev/null 2>&1
			wget -O /etc/openvpn/default.tar $api_host"/asset_script/openvpn/default.tar" >/dev/null 2>&1
			cd /etc/openvpn/ >/dev/null 2>&1
			tar xf openvpn.tar >/dev/null 2>&1
			tar xf default.tar >/dev/null 2>&1
			cp sysctl.conf /etc/ >/dev/null 2>&1
			cp before.rules /etc/ufw/ >/dev/null 2>&1
			cp ufw /etc/default/ >/dev/null 2>&1
			rm sysctl.conf >/dev/null 2>&1
			rm before.rules >/dev/null 2>&1
			rm ufw >/dev/null 2>&1
			service openvpn restart >/dev/null 2>&1

			#install squid3

			apt-get -y install squid3 >/dev/null 2>&1;
			cp /etc/squid3/squid.conf /etc/squid3/squid.conf.bak >/dev/null 2>&1
			wget -O /etc/squid3/squid.conf $api_host"/asset_script/squid/squid.conf" >/dev/null 2>&1
			sed -i $MYIP2 /etc/squid3/squid.conf >/dev/null 2>&1;
			service squid3 restart >/dev/null 2>&1
			echo -e 'Squid3 was installed.'
			
			#config client
			cd /etc/openvpn/ >/dev/null 2>&1
			wget -O /etc/openvpn/client.ovpn $api_host"/asset_script/openvpn/client.ovpn" >/dev/null 2>&1
			sed -i $MYIP2 /etc/openvpn/client.ovpn >/dev/null 2>&1;
			cp client.ovpn /root/ >/dev/null 2>&1
			echo -e 'Openvpn Config was installed.'
			
			ufw allow ssh >/dev/null 2>&1
			ufw allow 1194/tcp >/dev/null 2>&1
			ufw allow 8080/tcp >/dev/null 2>&1
			ufw allow 8000/tcp >/dev/null 2>&1
			ufw allow 3128/tcp >/dev/null 2>&1
			ufw allow 80/tcp >/dev/null 2>&1
			ufw allow 443/tcp >/dev/null 2>&1
			yes | sudo ufw enable >/dev/null 2>&1
			
			sed -i '/Port 443/d' /etc/ssh/sshd_config
			echo "Port 443" >> /etc/ssh/sshd_config
			echo -e 'SSH Config was installed.'
			
			# download script
			cd /usr/bin >/dev/null 2>&1
			wget -O member $api_host"/asset_script/menu/member.sh" >/dev/null 2>&1
			wget -O menu $api_host"/asset_script/menu/menu.sh" >/dev/null 2>&1
			wget -O usernew $api_host"/asset_script/menu/usernew.sh" >/dev/null 2>&1
			wget -O speedtest $api_host"/asset_script/menu/speedtest_cli.py" >/dev/null 2>&1
			wget -O userd $api_host"/asset_script/menu/deluser.sh" >/dev/null 2>&1
			wget -O trial $api_host"/asset_script/menu/trial.sh" >/dev/null 2>&1
			echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot >/dev/null 2>&1
			#echo "* * * * * service dropbear restart" > /etc/cron.d/dropbear
			chmod +x member >/dev/null 2>&1
			chmod +x menu >/dev/null 2>&1
			chmod +x usernew >/dev/null 2>&1
			chmod +x speedtest >/dev/null 2>&1
			chmod +x userd >/dev/null 2>&1
			chmod +x trial >/dev/null 2>&1
			
			clear
			
			echo -e '\n\n'
			echo -e '\t\t#################################################'
			echo -e '\t\t#\t\t\t\t\t\t#'
			echo -e '\t\t#    This script made by Jiraphat Yuenying\t#'
			echo -e '\t\t#\t\t\t\t\t\t#'
			echo -e '\t\t#\t  Goto : '$MYIP'/install\t\t#'
			echo -e '\t\t#\t\t\t\t\t\t#'
			echo -e '\t\t#\t       for complete install\t\t#'
			echo -e '\t\t#\t\t\t\t\t\t#'
			echo -e '\t\t#\t        "menu" for show menu\t\t#'
			echo -e '\t\t#\t\t\t\t\t\t#'
			echo -e '\t\t#\t\t    Thank you\t\t\t#'
			echo -e '\t\t#\t\t\t\t\t\t#'
			echo -e '\t\t#\t  You must be restart server \t\t#'
			echo -e '\t\t#\t\t\t\t\t\t#'
			echo -e '\t\t#################################################'
			echo -e '\n'
			printf 'Restart server ? (y/n): '
			read a
			if [ $a == 'y' ] || [ $a == 'Y' ]
			then
			reboot
			else
			exit
			fi
		else
			echo -e '\n'
			echo -e "Cancle by user."
			echo -e '\n'
		fi
	else
		echo -e '\n\n'
		echo -e '\t\t#################################################'
		echo -e '\t\t#\t\t\t\t\t\t#'
		echo -e '\t\t#\t    This key is not available\t\t#'
		echo -e '\t\t#\t\t\t\t\t\t#'
		echo -e '\t\t#\t\tLog : '$HTTP_BODY'\t\t\t#'
		echo -e '\t\t#\t\t\t\t\t\t#'
		echo -e '\t\t#\t   You can get key in link below\t#'
		echo -e '\t\t#\t\t\t\t\t\t#'
		echo -e '\t\t#\t    Website  : '$webreseller'\t\t#'
		echo -e '\t\t#\t\t\t\t\t\t#'
		echo -e '\t\t#################################################'
		echo -e '\n\n'
	fi
else
	printf '\n\n'
	printf '\t\t\t\t#####################\n'
	printf '\t\t\t\t# Cannot check key. #\n'
	printf '\t\t\t\t# Server has error. #\n'
	printf '\t\t\t\t# Try again later.  #\n'
	printf '\t\t\t\t#####################\n'
	exit 1
fi
