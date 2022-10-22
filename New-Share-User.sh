#!/bin/bash
echo -n "New Users Name?: "
read name
useradd -M -s /sbin/nologin $name
usermod -aG smbuser $name
smbpasswd -a $name
smbpasswd -e $name
systemctl restart smbd