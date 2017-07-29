#!/bin/bash
clear

oc_off="oc_files/oc_off"
oc_on="oc_files/oc_on"
php_ini="/etc/php/7.0/fpm/php.ini"
restart_command="systemctl restart"
if grep -q "opcache.enable=1" /etc/php/7.0/fpm/php.ini; then
    oc_status="Opcache is currently: ENABLED"
    oc_status_2="disable"
    oc_status_3="off"
    default_answer="--defaultno"
else
    oc_status="Opcache is currently: DISABLED"
    oc_status_2="enable"
    oc_status_3="on"
fi
Service[0]='mysql'
Service[1]='nginx'
Service[2]='php7.0-fpm'

turn_off_opscache(){
	cp $oc_off $php_ini
	echo ""
	echo "Setting: opcache.enable=0"
	echo ""
	echo "Copying: $oc_off to $php_ini..."
	echo ""
	echo "Service Status:"
	for service_name in "${Service[@]}"
	do
		$restart_command $service_name

# Start Progress Bar
{
	for ((i = 0 ; i <= 100 ; i+=5)); do
		sleep 0.04
		echo $i
	done
} | whiptail --gauge "Restarting $service_name" 6 50 0
# End Progress Bar
service_status="$(systemctl status $service_name | grep Active | awk '{print $2,$3,":",$9,$10}')"
echo -e "$service_name - \e[0;32m$service_status\e[0m"
done
echo ""
if grep -q "opcache.enable=0" /etc/php/7.0/fpm/php.ini; then
    echo ""
    echo -e "\e[0;32mSuccess!\e[0m"
    echo -e "Confirmed: Opcache \e[1;31mDisabled\e[0m..."
    echo -e "opcache.enable=\e[1;31m0\e[0m was found in /etc/php/7.0/fpm/php.ini"
else
    echo ""
    echo -e "\e[1;31mFAILED!!\e[0m"
    echo -e "Opcache \e[0;32mENABLED\e[0m"
    echo -e "opcache.enable=\e[0;32m0\e[0m was found in /etc/php/7.0/fpm/php.ini!!"
fi
echo ""
}

if [[ "$-" == *i* ]]; then
	if ! whiptail --title "Turn $oc_status_3 OpsCache" --yesno --yes-button "Enable" --no-button "Disable" $default_answer "$oc_status\n\nAre you sure you want to $oc_status_2 OpsCache?" 10 40 ;then
		turn_off_opscache

	else
		cp $oc_on $php_ini
		echo ""
		echo "Setting: opcache.enable=1"
		echo ""
		echo "Copying: $oc_on to $php_ini..."
		echo ""
		echo "Service Status:"

		for service_name in "${Service[@]}"
		do
			$restart_command $service_name
# Start Progress Bar
{
	for ((i = 0 ; i <= 100 ; i+=5)); do
		sleep 0.04
		echo $i
	done
} | whiptail --gauge "Restarting $service_name" 6 50 0
# End Progress Bar
service_status="$(systemctl status $service_name | grep Active | awk '{print $2,$3,":",$9,$10}')"
echo -e "$service_name - \e[0;32m$service_status\e[0m"
done
if grep -q "opcache.enable=1" /etc/php/7.0/fpm/php.ini; then
    echo ""
    echo -e "\e[0;32mSuccess!\e[0m"
    echo -e "Confirmed: Opcache \e[0;32mEnabled\e[0m..."
    echo -e "opcache.enable=\e[0;32m1\e[0m was found in /etc/php/7.0/fpm/php.ini"
else
    echo ""
    echo -e "\e[1;31mFAILED!!\e[0m"
    echo -e "Opcache \e[1;31mDISABLED\e[0m"
    echo -e "opcache.enable=\e[1;31m0\e[0m was found in /etc/php/7.0/fpm/php.ini!!"
fi
echo ""
fi
else
	echo "Bye!"
fi
