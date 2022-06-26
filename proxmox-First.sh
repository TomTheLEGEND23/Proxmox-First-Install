#!/bin/bash
#author: Tom Steenvoorden
#Github: https://github.com/TomTheLEGEND23

echo "You can find this script on: https://github.com/TomTheLEGEND23/Proxmox-First-Install"
echo "Starting"
echo "If it looks like the script stopped just wait."
sleep 5

echo "Would You Like a Dark interface? [Press Enter to skip]: "
read dark
echo "Would you Like To have Some Start ISOs/containers? Alpine, Ubuntu, Debian [Press Enter to skip]"
read ISO
echo  "Would you like to setup and configure samba shares? [Press Enter to skip]:"
read samba
if [[ -z $samba ]]; then
 echo
else
 echo "where Should the Shares be stored? [Type Full path]"
 read sharel
fi
echo  "Would you like to have a OpenVpnserver? [Press Enter to skip]:"
read vpn

#configuring Proxmox Repos.
echo "#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise" > /etc/apt/sources.list.d/pve-enterprise.list
echo "#Proxmox community update Repo" >> /etc/apt/sources.list
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" >> /etc/apt/sources.list

#Updating Proxmox and install samba
apt update
apt install samba tree cron -y
apt full-upgrade -y

#Lets Configure Automatic Updates
crontab -e
echo "apt update && apt full-upgrade -y" > /root/update.sh
chmod +x /root/update.sh
echo "0 2 * * * /bin/bash /root/update.sh" >> /var/spool/cron/crontabs/root
crontab -l

#Lets Setup A dark Interface
if [[ -z $dark ]]; then
 echo "skipping adding dark interface."
else
 bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
fi

#Lets Get Some ISO's and Container Template.
if [[ -z $ISO ]]; then
 echo "Skipping Getting ISOs"
else 
 echo "Downlaoding Ubuntu Server ISO"
 wget -P /var/lib/vz/template/iso -o /dev/null --show-progress -q https://ubuntu.mirror.wearetriple.com/releases/20.04.4/ubuntu-20.04.4-live-server-amd64.iso
 echo "Done"

 echo "Downlaoding Alpine Container"
 wget -P /var/lib/vz/template/cache/ -o /dev/null --show-progress -q http://download.proxmox.com/images/system/alpine-3.9-default_20190224_amd64.tar.xz
 echo "Done"
 echo 
 echo "Downloading Ubuntu Container"
 wget -P /var/lib/vz/template/cache/ -o /dev/null --show-progress -q http://download.proxmox.com/images/system/ubuntu-21.10-standard_21.10-1_amd64.tar.zst
 echo "Done"
 echo 
 echo  "Would you like to setup and configure samba shares? [Press Enter to skip]"
 echo "Downloading Debain Container"
 wget -P /var/lib/vz/template/cache/ -o /dev/null --show-progress -q http://download.proxmox.com/images/system/debian-11-standard_11.3-1_amd64.tar.zst
 echo "Done"
fi

if [[ -z $samba ]]; then
 echo "Skipping Samba"
else
 #lets Back-Up samba's Config
 mkdir /config.back
 cp /etc/samba/smb.conf /config.back/smb.conf
 #Lets configure samba
 echo -n "Please supply Username for share login: "
 read SMBuser
 addgroup smbuser
 useradd -M -s /sbin/nologin $SMBuser
 usermod -aG smbuser $SMBuser
 echo "!!!Dont Mis type. you Only Get One Chance!!!"
 smbpasswd -a $SMBuser
 smbpasswd -e $SMBuser
 Drive= $sharel
 numer=1
 number=0
 echo -n "how many shares would you like to add?: "
 read ShareA
 while [[ $number != $ShareA ]];do
    echo -n "Name Share number $numer: [Press enter to Cancel]: "
    read Share
    if [[ -z $Share ]]; then
     echo "Canceling making share."
     sleep 1
     break
    else
     mkdir $Drive/$Share
     echo " " >> /etc/samba/smb.conf
     echo "[$Share]" >> /etc/samba/smb.conf
     echo "comment = $Share" >> /etc/samba/smb.conf
     echo "path = $Drive/$Share" >> /etc/samba/smb.conf
     echo "read only = no" >> /etc/samba/smb.conf
     echo "browsable = yes" >> /etc/samba/smb.conf
     chown root:smbuser $Drive/$Share
     chmod -R 770 $Drive/$Share
     let number++; let numer++
    fi
 done
 systemctl restart smbd
 systemctl enable smbd
 systemctl status smbd
 sleep 10
fi

if [[ -z $vpn ]]; then
 echo "Skipping Vpn"
else
 #Lest Download OpenVpn Script.  Soure: https://github.com/Nyr/openvpn-install
 wget https://git.io/vpn -O openvpn-install.sh
 chmod +x openvpn-install.sh
 bash openvpn-install.sh
 echo "Would you like a second user? [Press Enter to skip]: "
 read vpn2user
 if [[ -z $vpn2user ]]; then
     echo "Skipping Second user"
 else
     #Lets run the script again to make a second user.
     bash openvpn-install.sh
 fi
 #Tell User Where the OpenVpn Login is Located.
 echo " "
 echo "You can Find the .ovpn in the home folder of the current logged in user."
 exit
fi

echo "Script Is Done!"