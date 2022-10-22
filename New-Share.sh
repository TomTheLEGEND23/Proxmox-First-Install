#!/bin/bash
Drive="ZFS-Drive"
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
  mkdir /$Drive/$Share
  echo " " >> /etc/samba/smb.conf
  echo "[$Share]" >> /etc/samba/smb.conf
  echo "comment = $Share" >> /etc/samba/smb.conf
  echo "path = /$Drive/$Share" >> /etc/samba/smb.conf
  echo "read only = no" >> /etc/samba/smb.conf
  echo "browsable = yes" >> /etc/samba/smb.conf
  chown root:smbuser /$Drive/$Share
  chmod -R 770 /$Drive/$Share
  let number++; let numer++
 fi
done

systemctl restart smbd