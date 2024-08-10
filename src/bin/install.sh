#!/bin/sh

# Load functions.
. /functions.sh

mkdir /temp
mkdir /backup

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mSearching for the USB Drive..."
sleep 2
for x in a b c d e f g h i j k
do
	device="/dev/sd"$x
  mount $device"1" /temp > /dev/null
  if [ $? = 0 ]; then
  	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mPotential USB Drive found - \e[32m\e[1m$device\e[39m\e[0m!"
  	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mSearching for Batocera installation archive & other files..."
		if [ -e /temp/bzImage ] && [ -e /temp/initramfs.cpio.gz ] && ls /temp/batocera_ps4linux*.tar.xz 1> /dev/null 2>&1; then
			echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[32m\e[1mDevice $device has the necessary files to install Batocera for PS4!"
			break;
		fi
		umount /temp
	fi
	if [ $x = "k" ]; then
		echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[31m\e[1mERROR! Valid USB Drive not found! Try to reinsert the USB Drive and run \e[32m\e[1mexec install.sh."
		echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mIf issue persists, visit \e[32m\e[1mhttps://ps4linux.com/s/batocera \e[39m\e[0mfor help."
		echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mPress Ctrl+Alt+Del to reboot into PS4 Orbis."
	rescueshell
	fi
done

sizeusb=$(fdisk -l | grep -i "Disk $device" | awk '{print $3}')
mu=$(fdisk -l | grep -i "Disk $device" | awk '{print $4}')
sizeusb=$(echo $sizeusb | awk -F',' '{print $1}')
mu=$(echo $mu | awk -F',' '{print $1}')

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[32m\e[1mSize of selected USB Drive: $sizeusb $mu"
if [ "$mu" != "GB" ] || [ $sizeusb -lt 12 ]; then
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[31m\e[1mERROR! Insufficient space on USB Drive! Use a USB Drive with atleast 12GB storage."
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mIf issue persists, visit \e[32m\e[1mhttps://ps4linux.com/s/batocera \e[39m\e[0mfor help."
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mPress Ctrl+Alt+Del to reboot into PS4 Orbis."
	exit
fi

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mBeginning Batocera for PS4 installation wizard..."
sleep 2
echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mDo you wish to use WiFi? [y/n]"
read wifiopt
while true; do
	case $wifiopt in
  	y | Y | yes | Yes)
    	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mProvide WiFi SSID/Access Point Name (case sensitive)"
    	read wifissid
    	while true; do
    		if [[ -z "$wifissid" ]]; then
   				echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mProvide WiFi SSID/Access Point Name (case sensitive)"
    			read wifissid
    		else
    			break
				fi
    	done
    	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mProvide WiFi Password (case sensitive)"
    	stty -echo
    	read wifipw
    	stty echo
    	while true; do
    		if [[ -z "$wifipw" ]]; then
   				echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mProvide WiFi Password (case sensitive)"
    			read wifipw
    		else
    			break
				fi
    	done
    	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mBeginning USB device setup for Batocera installation..."
    	sleep 2
    	break
    	;;
	
  	n | N | no | No)
    	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mBeginning USB device setup for Batocera installation..."
    	sleep 2
    	break
    	;;
	
  	*)
    	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mKindly type \e[32m\e[1my \e[39m\e[0mfor yes and \e[31m\e[1mn \e[39m\e[0mfor no."
    	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mDo you wish to use WiFi? [y/n]"
    	read wifiopt
    	;;
	esac
done

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mCopying files to /backup..."
tarname=$(cd /temp && ls | grep batocera_ps4linux*.tar.xz);

echo -e "\e[34m\e[1m>> \e[39m\e[0mCopying \e[34m\e[1m$tarname\e[39m\e[0m..."
pv /temp/${tarname} > /backup/${tarname}

if [ $? -ne  0 ]; then
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[31m\e[1mERROR! Insufficient RAM!"
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mTry using 1GB VRAM payload on https://jb.ps4linux.com or your exploit host."
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mPress Ctrl+Alt+Del to reboot into PS4 Orbis."
	rescueshell
fi

echo -e "\e[34m\e[1m>> \e[39m\e[0mCopying \e[34m\e[1minitramfs.cpio.gz\e[39m\e[0m..."
pv /temp/initramfs.cpio.gz > /backup/initramfs.cpio.gz
if [ $? -ne  0 ]; then
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[31m\e[1mERROR! Insufficient RAM!"
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mTry using 1GB VRAM payload on https://jb.ps4linux.com or your exploit host."
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mPress Ctrl+Alt+Del to reboot into PS4 Orbis."
	rescueshell
fi

echo -e "\e[34m\e[1m>> \e[39m\e[0mCopying \e[34m\e[1mbzImage\e[39m\e[0m..."
pv /temp/bzImage > /backup/bzImage
if [ $? -ne  0 ]; then
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[31m\e[1mERROR! Insufficient RAM!"
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mTry using 1GB VRAM payload on https://jb.ps4linux.com or your exploit host."
	echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mPress Ctrl+Alt+Del to reboot into PS4 Orbis."
	rescueshell
fi

umount /temp

sleep 2
echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mCreating partitions for Batocera..."
(
echo "o"
echo "d"
echo "n"
echo "p"
echo "1"
echo #default
echo "+50M"
echo "n"
echo "p"
echo "2"
echo #default
echo "+10G"
echo "n"
echo "p"
echo "3"
echo #default
echo #default
echo "w"
echo "q"
) | fdisk $device > /dev/null

sleep 2
echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mFormatting partitions. Please wait..."
while sleep 0.2; do printf "."; done &
mkfs.vfat $device"1" > /dev/null
mke2fs -t ext4 -F -L batocera -O ^has_journal $device"2" > /dev/null 2>&1
mke2fs -t ext4 -F -L GAMES -O ^has_journal $device"3" > /dev/null 2>&1
kill $!

sleep 1
echo -e "\n\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mMounting new partitions and copying files in /backup to them..."
mount $device"1" /temp
echo -e "\e[34m\e[1m>> \e[39m\e[0mCopying \e[34m\e[1minitramfs.cpio.gz\e[39m\e[0m..."
pv /backup/initramfs.cpio.gz > /temp/initramfs.cpio.gz
echo -e "\e[34m\e[1m>> \e[39m\e[0mCopying \e[34m\e[1mbzImage\e[39m\e[0m..."
pv /backup/bzImage > /temp/bzImage

sleep 1
mount $device"2" /newroot

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mBeginning Batocera installation..."
sleep 5

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mExtracting Batocera for PS4..."
pv /backup/${tarname} | tar -xpJf - -C /newroot --numeric-owner --warning=none

#Add batocera conf files
echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mConfiguring WiFi and/or Batocera Data Drive..."
output=$(blkid ${device}3 | awk 'BEGIN{FS="[=\"]"} {print $(NF-4)}')
if [ -n "$wifissid" ] && [ -n "$wifipw" ]; then
cat <<EOT >> /newroot/boot/batocera-boot.conf
sharedevice=DEV $output
EOT
cat <<EOT >> /temp/batocera.conf
wifi.enabled=1
wifi.ssid=$wifissid
wifi.key=$wifipw
EOT
umount /temp
cat <<EOT >> /newroot/boot/postshare.sh
#!/bin/bash
sleep 5
if [ -f /media/NO_LABEL/batocera.conf ]; then
	mv -f /media/NO_LABEL/batocera.conf /userdata/system/batocera.conf
fi
EOT
else
cat <<EOT >> /newroot/boot/batocera-boot.conf
sharedevice=DEV $output
EOT
fi

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mCleaning up..."
rm /backup/*
rm -R /newroot/lost+found

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mAdding EAP key..."
cp /key/eap_hdd_key.bin /newroot/etc/cryptmount > /dev/null
#cp /lib/firmware/edid/my_edid.bin /newroot/lib/firmware/edid > /dev/null

echo -e "\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mWaiting for 10 seconds before trying to boot Batocera..."
while sleep 1; do printf "."; done &
sleep 10
kill $!

#Start Batocera boot
echo -e "\n\e[31m\e[1m>\e[34m\e[1m>\e[31m\e[1m> \e[39m\e[0mBooting Batocera for PS4. Please wait..."
emount /newroot/usr > /dev/null
cleanup > /dev/null
moveDev > /dev/null
eumount /sys /proc > /dev/null
run_hooks pre_switch_root > /dev/null
sleep 3
clear
boot_newroot > /dev/null
rescueshell
