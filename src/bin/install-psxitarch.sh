#!/bin/sh

mkdir /temp
mkdir /backup

echo "Try to find the right usb"
for x in a b c d e f g h i j k
do
	device="/dev/sd"$x
    mount $device"1" /temp
    if [ $? = 0 ]; then
		if [ -e /temp/bzImage ] && [ -e /temp/initramfs.cpio.gz ] && [ -e /temp/psxitarch.tar.xz ]; then
			echo "Device $device has the necessary files to install psxitarch linux"
			break;
		fi
		umount $device"1"
	fi
	if [ $x = "k" ]; then
		echo "ERROR! No valid usb device found! Try remove, reinsert the usb device and run again install-psxitarch.sh"
		echo "Se error persist probably your usb device is not formatted correctly or some file are missing or corrupted" 
		exit
	fi
done

sizeusb=$(fdisk -l | grep -i "Disk $device" | awk '{print $3}')
mu=$(fdisk -l | grep -i "Disk $device" | awk '{print $4}')
sizeusb=$(echo $sizeusb | awk -F',' '{print $1}')
mu=$(echo $mu | awk -F',' '{print $1}')

echo "Size usb device: $sizeusb $mu"
if [ "$mu" != "GB" ] || [ $sizeusb -lt 12 ]; then
	echo "Not enough space on the usb device, please insert one usb with almost 12GB of free space and run again install-psxitarch.sh"
	exit
fi

echo "Copy psxitarch, the bzImage and the initramfs to /backup"
cp /temp/psxitarch.tar.xz /backup
if [ $? -ne  0 ]; then
	echo "No enough space in RAM availble!"
	echo "Use this payload to install psxitarch: https://psxita.it/linux-loader-vram1"
	exit
fi
cp /temp/initramfs.cpio.gz /backup
if [ $? -ne  0 ]; then
	echo "No enough space in RAM availble!"
	echo "Use this payload to install psxitarch: https://psxita.it/linux-loader-vram1"
	exit
fi
cp /temp/bzImage /backup
if [ $? -ne  0 ]; then
	echo "No enough space in RAM availble!"
	echo "Use this payload to install psxitarch: https://psxita.it/linux-loader-vram1"
	exit
fi
umount $device"1"

echo "Create a smallest fat32 and a ext4 partition"
(
echo "o" #fdisk can't write device with disklabel GPT
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
echo #default
echo "w"
echo "q"
) | fdisk $device

echo "Format fat32 partition"
mkfs.vfat $device"1"

echo "Remount the fat32 partition and copy in the initramfs and bzImage"
mount $device"1" /temp
cp /backup/initramfs.cpio.gz /temp
cp /backup/bzImage /temp
umount $device"1"

echo "Format the ext4 partition to psxitarch and mount it to /newroot"
mke2fs-new -t ext4 -F -L psxitarch -O ^has_journal $device"2" 
mount $device"2" /newroot

echo "Installing psxitarch linux, please wait, DON'T REMOVE THE USB DEVICE OR SHUTDOWN THE PS4!"
sleep 5

echo "Extract backup of psxitarch to /newroot"
tar -xvpJf /backup/psxitarch.tar.xz -C /newroot --numeric-owner

echo "Psxitarch linux installed with success! Clean some garbage.."
rm /backup/*
rm -R /newroot/lost+found

echo "Add eap key and edid.."
cp /key/eap_hdd_key.bin /newroot/etc/cryptmount
cp /lib/firmware/edid/my_edid.bin /newroot/lib/firmware/edid

echo "Booting psxitarch linux, please wait.." 
exec switch_root /newroot /newroot/sbin/init &
sleep 2 &&
exec switch_root /newroot /newroot/sbin/init &
sleep 2 &&
exec switch_root /newroot /newroot/sbin/init
