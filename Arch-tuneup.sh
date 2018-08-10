#!/bin/bash

#This is for service management Prolly not a great idea, but...
cat <<_EOF_
This is usually better off left undone, only disable services you know 
you will not need or miss. I can not be held responsible if you brick your system.
Handle with caution.
_EOF_

echo "Which would you like to do?"
echo "1 - enable service"
echo "2 - disable service"
echo "3 - save a copy of all the services on your system to a text file"
echo "4 - Exit without doing anything"

read operation;
 
case $operation in
	1) 
		systemctl list-unit-files --type=service | grep disabled
		sleep 3
		echo "Please enter the name of a service to enable"
		read service
		sudo systemctl enable $service
	;;
	2)
		systemctl list-unit-files --type=service | grep enabled
		sleep 3
		echo "Please enter the name of a service to disable"
		read service 
		sudo systemctl disable $service
	;;
	3)
		systemctl list-unit-files --type=service >> services.txt
		echo "Thank you for your patience"
		sleep 3
	;;
	4)
		echo "Smart choice."
		sleep 2
	;;
esac

#This can repair your browsers
cat << _EOF_
This can fix a lot of the usual issues with a few of the bigger browsers. 
These can include performance hitting issues. If your browser needs a tuneup,
it is probably best to do it in the browser itself, but when you just want something
fast, this can do it for you. More browsers and options are coming.
_EOF_
echo "Would you like to repair your browser?(Y/n)"
read answer
while [ $answer == Y ];
do
 #Look for the following browsers
 browser1="$(find /usr/bin/firefox)"
 browser2="$(find /usr/bin/vivaldi*)"
 browser3="$(find /usr/bin/palemoon)"
 browser4="$(find /usr/bin/google-chrome*)"
 browser5="$(find /usr/bin/chromium)"
 browser6="$(find /usr/bin/opera)"
 browser7="$(find /usr/bin/waterfox)"

 echo $browser1
 echo $browser2
 echo $browser3
 echo $browser4
 echo $browser5
 echo $browser6
 echo $browser7

 sleep 1

 echo "choose the browser you wish to reset"
 echo "1 - Firefox"
 echo "2 - Vivaldi" 
 echo "3 - Pale Moon"
 echo "4 - Chrome"
 echo "5 - Chromium"
 echo "6 - Opera"
 echo "7 - Vivaldi-snapshot"
 echo "8 - Waterfox"

 read operation;

 case $operation in
  	 1)
	 sudo cp -r ~/.mozilla/firefox ~/.mozilla/firefox-old
	 sudo rm -r ~/.mozilla/firefox/profile.ini 
	 echo "Your browser has now been reset"
	 sleep 1
 ;;
	 2)
	 sudo cp -r ~/.config/vivaldi/ ~/.config/vivaldi-old
	 sudo rm -r ~/.config/vivaldi/* 
	 echo "Your browser has now been reset"
	 sleep 1
 ;;
	 3)
	 sudo cp -r ~/'.moonchild productions'/'pale moon' ~/'.moonchild productions'/'pale moon'-old
	 sudo rm -r ~/'.moonchild productions'/'pale moon'/profile.ini 
	 echo "Your browser has now been reset"
	 sleep 1
 ;;
	 4)
	 sudo cp -r ~/.config/google-chrome ~/.config/google-chrome-old
	 sudo rm -r ~/.config/google-chrome/*
	 echo "Your browser has now been reset"
	 sleep 1 
 ;;
	 5)
	 sudo cp -r ~/.config/chromium ~/.config/chromium-old
	 sudo rm -r ~/.config/chromium/*
	 echo "Your browser has now been reset"
	 sleep 1
 ;;
 	 6)
	 sudo cp -r ~/.config/opera ~/.config/opera-old
	 sudo rm -r ~/.config/opera/* 
	 echo "Your browser has now been reset"
	 sleep 1
 ;;
	 7)
	 sudo cp -r ~/.config/vivaldi-snapshot ~/.config/vivaldi-snapshot-old
	 sudo rm -r ~/.config/vivaldi-snapshot/*
	 echo "Your browser has now been reset"
	 sleep 1
 ;;
	 8)
	 sudo cp -r ~/.waterfox ~/.waterfox-old
	 sudo rm -r ~/.waterfox/*
	 echo "Your browser has now been reset"
	 sleep 1
 ;;
	 *)
	 echo "No browser for that entry exists, please try again!"
	 sleep 1 
 esac
	
 #Change the default browser
 echo "Would you like to change your default browser also?(Y/n)"
 read answer
 while [ $answer == Y ];
 do
	 echo "Enter the name of the browser you wish to use"
	 read browser
	 xdg-settings set default-web-browser $browser.desktop
 break
 done
break
done

#This refreshes systemd in case of failed or changed units
sudo systemctl daemon-reload

#This will try to ensure you have a strong network connection
for c in computer;
do 
	ping -c4 google.com 
	if [[ $? -eq 0 ]];
	then 
		echo "Connection successful"
	else
		interface=$(ip -o -4 route show to default | awk '{print $5}')
		sudo dhclient -v -r && sudo dhclient
		sudo systemctl stop NetworkManager.service
		sudo systemctl disable NetworkManager.service
		sudo systemctl enable NetworkManager.service
		sudo systemctl start NetworkManager.service
		sudo ip link set $interface up #Refer to networkconfig.log
	fi
done 

#This attempts to rank mirrors and update your system
distribution=$(cat /etc/issue | awk '{print $1}')
if [[ $distribution == Manjaro ]];
then
	sudo pacman-mirrors --fasttrack 5 && sudo pacman -Syyu --noconfirm
else
	sudo reflector -l 50 -f 20 --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d
	sudo rankmirrors -n 0 /etc/pacman.d/antergos-mirrorlist > /tmp/antergos-mirrorlist && sudo cp /tmp/antergos-mirrorlist /etc/pacman.d
	sudo pacman -Syyu --noconfirm
fi

#This gives a list of available kernels and offers to both install and uninstall them
echo "What would you like to do today?"
echo "1 - Install new kernel(s)"
echo "2 - Uninstall kernel(s)"
echo "3 - save a list of available and installed kernels to a text file"
echo "4 - skip"

read operation;

case $operation in
	1)
	sudo mhwd-kernel -l
	sleep 3
	echo "Are you sure you want to install a kernel?(Y/n)"
	read answer
	while [ $answer == Y ];
	do
		echo "Enter the name of the kernel you wish to install"
		read kernel
		sudo mhwd-kernel -i $kernel
	break
	done
;;
	2)
	sudo mhwd-kernel -li 
	sleep 3
	echo "Are you sure you want to remove a kernel?(Y/n)"
	read answer
	while [ $answer == Y ];
	do
		echo "Enter the name of the kernel you wish to remove"
		read kernel
		sudo mhwd-kernel -r $kernel
	break
	done
;;
	3)
	sudo mhwd-kernel -l >> kernels.txt
	echo "######################################################" >> kernels.txt
	sudo mhwd-kernel -li >> kernels.txt
;;
	4)
	echo "Skipping"
;;
esac

#This will reload the firewall to ensure it's enabled
sudo ufw reload

#This will clean the cache
sudo rm -r .cache/*
sudo rm -r .thumbnails/*
sudo rm -r ~/.local/share/Trash
sudo rm -r ~/.nv/*
sudo rm -r ~/.npm/*
sudo rm -r ~/.w3m/*
sudo rm -r ~/.esd_auth #Best I can tell cookie for pulse audio
sudo rm -r ~/.local/share/recently-used.xbel
sudo rm -r /tmp/* 
find ~/Downloads/* -type f -mtime +1 -exec rm {} \; #Deletes contents older than one day
history -cw && cat /dev/null/ > ~/.bash_history

#This clears the cached RAM 
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"

#This could clean your Video folder and Picture folder based on a set time
TRASHCAN=~/.local/share/Trash/
find ~/Videos/* -mtime +30 -exec mv {} $TRASHCAN \; #throws away month old content
find ~/Pictures/* -mtime +30 -exec mv {} $TRASHCAN \; #The times can be changed

#Sometimes it's good to check for and remove broken symlinks
find -xtype l -delete

#clean some unneccessary files leftover by applications in home directory
find $HOME -type f -name "*~" -print -exec rm {} \;

#Optionally, you can remove old backups to make room for new ones
find /Backups/* -mtime +30 -exec rm {} \;
 
#This helps get rid of old archived log entries
sudo journalctl --vacuum-size=25M

#This will remove orphan packages from pacman 
sudo pacman -Rsn --noconfirm $(pacman -Qqdt)

#This allows the user to remove unwanted shite
echo "Would you like to remove any other unwanted shite?(Y/n)"
read answer 
while [ $answer == Y ];
do
	echo "Please enter the name of any software you wish to remove"
	read software
	sudo pacman -Rs --noconfirm $software
	break
done

#Optional This will remove the pamac cached applications and older versions
cat <<_EOF_
It's probably not a great idea to be cleaning this part of the system
all willy nilly, but here is a way to free up some space before doing
backups that may cause you to not be able to downgrade, so be careful. 
It is possible and encouraged to clean all but the latest three versions of software on your
system that you may not need, but this removes all backup versions. 
You will be given a choice, but it is strongly recommended that you use the simpler option to 
remove only up to the latest three versions of your software. Thanks. 
_EOF_

echo "What would you like to do?"
echo "1 - Remove up to the latest three versions of software"
echo "2 - Remove all cache except for the version on your system"
echo "3 - Remove all cache from every package and every version"
echo "4 - Skip this step"

read operation;

case $operation in 
	1)
	sudo paccache -rvk3
	sleep 3
	;;
	2)
	sudo pacman -Sc --noconfirm 
	sleep 3
	;;
	3)
	sudo pacman -Scc --noconfirm
	sleep 3
	;;
	4)
	echo "NICE!"
	;;
esac

#This refreshes index cache
sudo updatedb && sudo mandb 

#This will reload the firewall to ensure it's enabled
sudo ufw reload

#update the grub 
sudo grub-mkconfig -o /boot/grub/grub.cfg

#This runs a disk checkup and attempts to fix filesystem
sudo touch /forcefsck 

#This tries to restore the home folder from backup
cat <<_EOF_
This tries to restore the home folder and nothing else, if you want to 
restore the entire system,  you will have to do that in a live environment.
This can, however, help in circumstances where you have family photos and
school work stored in the home directory. This also assumes that your home
directory is on the drive in question. 
_EOF_

Mountpoint=$(lsblk | awk '{print $7}' | grep /run/media/$USER/*)
if [[ $Mountpoint != /run/media/$USER/* ]];
then
	read -p "Please insert the backup drive and hit enter..."
	echo $(lsblk | awk '{print $1}')
	sleep 1
	echo "Please select the device from the list"
	read device
	sudo mount $device /mnt 
	sudo rsync -aAXv --delete --exclude={"*.cache/*","*.thumbnails/*"."*/.local/share/Trash/*"}  /mnt/$host-backups/* /home
	sudo sync 
	Restart
elif [[ $Mountpoint == /run/media/$USER/* ]];
then
	read -p "Found a block device at designated coordinates... If this is the preferred
	drive, try unmounting the device, leaving it plugged in, and running this again. Press enter to continue..."
fi

#Optional and prolly not needed
#sudo e4defrag / -c > fragmentation.log #only to be used on HDD

#This will sync any data and reboot the system
sudo sync && sudo systemctl reboot
