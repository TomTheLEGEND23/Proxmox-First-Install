#!/bin/bash
#author: Tom Steenvoorden

echo "Starting"
sleep 3

#configuring Proxmox Repos.
echo "#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise" >>  /etc/apt/sources.list.d/pve-enterprise.list
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
echo "Would You Like a Dark interface? [Press Enter to skip]: "
read dark
if [[ -z $dark ]]; then
 echo "skipping adding dark interface."
else
 bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
fi