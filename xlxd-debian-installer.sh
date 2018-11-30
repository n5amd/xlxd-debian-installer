#!/bin/bash
# A tool to install xlxd, your own D-Star Reflector.
# For more information, please visit: https://sadigitalradio.com

#Lets begin-------------------------------------------------------------------------------------------------
#Sanity checks
WHO=$(whoami)
#Have to be ROOT to run this script
if [ "$WHO" != "root" ]
then
  echo ""
  echo "You Must be root to run this script!!"
  exit 0
fi
#Has to be a Debian variant.
if [ ! -e "/etc/debian_version" ]
then
  echo ""
  echo "This script is only tested in Debian 9 and x64 cpu Arch. "
  exit 0
fi

#Gather variables.
XLXDREPO=https://github.com/LX3JL/xlxd.git
DIRDIR=$(pwd)
LOCAL_IP=$(ip a | grep inet | grep "eth0\|en" | awk '{print $2}' | tr '/' ' ' | awk '{print $1}')
SADREF=https://sadigitalradio.com/digital-radio-how-tos/create-xlx-xrf-d-star-reflector/

clear
echo ""
echo "XLX uses 3 digit numbers for its reflectors. For example: 032, 999, 099."
read -p "What 3 digit XRF number will you be using?  " XRFDIGIT
XFRNUM=XLX$XRFDIGIT
echo ""
echo "--------------------------------------"
read -p "What is the FQDN of the XLX Reflector dashboard? Example: xlx.domain.com.  " XLXDOMAIN
echo ""
echo "--------------------------------------"
read -p "What E-Mail address can your users send questions to?  " EMAIL
echo ""
echo "--------------------------------------"
read -p "What is the admins callsign?  " CALLSIGN
echo "------------------------------------------------------------------------------"
echo "Making install directories and installing dependicies...."
mkdir -p /root/reflector-install-files
mkdir -p /root/reflector-install-files/xlxd
mkdir -p /var/www/xlxd

#Install dependicies
apt-get update
apt-get -y install git build-essential apache2 php libapache2-mod-php php7.0-mbstring
a2enmod php7.0


echo "------------------------------------------------------------------------------"
#Install xlxd
#If the file is here already, then we dont need to compile on top of it. Remove the git clone directory and start over.
if [ -e /root/reflector-install-files/xlxd/xlxd/src/xlxd ]
then
   echo ""
   echo "It looks like you have already compiled XLXD. If you want to install/complile xlxd again, delete the directory '/root/reflector-install-files/xlxd' and run this script again. "
else
   echo "Downloading and compiling xlxd... "
   cd /root/reflector-install-files/xlxd
   git clone $XLXDREPO
   cd /root/reflector-install-files/xlxd/xlxd/src
   make clean
   make
   make install
fi
#Now the file should be there, if it compiled correctly.
if [ -e /root/reflector-install-files/xlxd/xlxd/src/xlxd ]
then
   echo "------------------------------------------------------------------------------"
   echo "It looks like everything compiled successfully. There is a 'xlxd' application file. "
else
   echo ""
   echo "UH OH!! I dont see the xlxd application file after attempting to compile."
   echo "The output above is the only indication as to why it might have failed.  "
   echo "Delete the directory '/root/reflector-install-files/xlxd' and run this script again. "
   echo ""
   exit 0
fi
echo "------------------------------------------------------------------------------"
echo "Finishing install..."
echo ""
echo ""
#get DMR files
wget -O /xlxd/dmrid.dat http://xlxapi.rlx.lu/api/exportdmr.php
#Copy files over
cp -R /root/reflector-install-files/xlxd/xlxd/dashboard/* /var/www/xlxd/
cp /root/reflector-install-files/xlxd/xlxd/scripts/xlxd /etc/init.d/xlxd
#Update the startup script
sed -i "s/ARGUMENTS=\"XLX270 158.64.26.132\"/ARGUMENTS=\"XLX$XRFDIGIT $LOCAL_IP 127.0.0.1\"/g" /etc/init.d/xlxd
update-rc.d xlxd defaults

echo "Updating config file"
XLXCONFIGDIR=/var/www/xlxd/pgs/config.inc.php
sed -i "s/your_email/$EMAIL/g" $XLXCONFIGDIR
sed -i "s/LX1IQ/$CALLSIGN/g" $XLXCONFIGDIR
sed -i "s/http:\/\/your_dashboard/$XLXDOMAIN/g" $XLXCONFIGDIR
sed -i "s/\/tmp\/callinghome.php/\/xlxd\/callinghome.php/g" $XLXCONFIGDIR
echo "------------------------------------------------------------------------------"
#Copy apache vhost directives
echo "Copying directives and reloading apache....."
cp $DIRDIR/templates/apache.tbd.conf /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/apache.tbd/$XLXDOMAIN/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/ysf-xlxd/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
a2ensite $XLXDOMAIN
systemctl reload apache2
echo "XLXD is finished installing and ready to be used. Please read the following..."
echo ""
echo "------------------------------------------------------------------------------"
echo "If you are requesting this reflector be added to all the pi-star host files as"
echo "a full time searchable reflector, you will need to request it on the xref forum boards."
echo "Once activated, the callinghome hash to backup will be in /xlxd/callinghome.php"
echo "More Information: $SADREF"
echo ""
echo ""
echo "If you are using this reflector as a test or for offline access you will  "
echo "need to configure the host files of the devices connecting to this server."
echo "There are many online tutorials on 'Editing pi-star host files'.          "
echo ""
echo ""
echo "          Your $XFRNUM dashboad should now be accessible at...            "
echo "          http://$XLXDOMAIN or http://$LOCAL_IP                           "
echo ""
echo ""
echo "You can make further customizations to the main config file $XLXCONFIGDIR."
echo "Be sure to thank the creators of xlxd for the ability to spin up          "
echo "your very own D-Star reflector.                                           "
echo ""

