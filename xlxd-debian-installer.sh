#!/bin/bash
# A tool to install xlxd, your own D-Star Reflector.
# For more information, please visit: https://n5amd.com
#Lets begin-------------------------------------------------------------------------------------------------
WHO=$(whoami)
if [ "$WHO" != "root" ]
then
  echo ""
  echo "You Must be root to run this script!!"
  exit 0
fi
if [ ! -e "/etc/debian_version" ]
then
  echo ""
  echo "This script is only tested in Debian 9 and x64 cpu Arch. "
  exit 0
fi
DIRDIR=$(pwd)
LOCAL_IP=$(ip a | grep inet | grep "eth0\|en" | awk '{print $2}' | tr '/' ' ' | awk '{print $1}')
INFREF=https://n5amd.com/digital-radio-how-tos/create-xlx-xrf-d-star-reflector/
XLXDREPO=https://github.com/LX3JL/xlxd.git
DMRIDURL=http://xlxapi.rlx.lu/api/exportdmr.php
WEBDIR=/var/www/xlxd
XLXINSTDIR=/root/reflector-install-files/xlxd
DEP="git build-essential apache2 php libapache2-mod-php php7.0-mbstring"
DEP2="git build-essential apache2 php libapache2-mod-php php7.3-mbstring"
VERSION=$(sed 's/\..*//' /etc/debian_version)
clear
echo ""
echo "XLX uses 3 digit numbers for its reflectors. For example: 032, 999, 099."
read -p "What 3 digit XRF number will you be using?  " XRFDIGIT
XRFNUM=XLX$XRFDIGIT
echo ""
echo "--------------------------------------"
read -p "What is the FQDN of the XLX Reflector dashboard? Example: xlx.domain.com.  " XLXDOMAIN
echo ""
echo "--------------------------------------"
read -p "What E-Mail address can your users send questions to?  " EMAIL
echo ""
echo "--------------------------------------"
read -p "What is the admins callsign?  " CALLSIGN
echo ""
echo ""
echo "------------------------------------------------------------------------------"
echo "Making install directories and installing dependicies...."
echo "------------------------------------------------------------------------------"
mkdir -p $XLXINSTDIR
mkdir -p $WEBDIR
apt-get update
if [ $VERSION = 9 ]
then
    apt-get -y install $DEP
elif [ $VERSION = 10 ]
then
    apt-get -y install $DEP2
fi
a2enmod php7.0
echo "------------------------------------------------------------------------------"
if [ -e $XLXINSTDIR/xlxd/src/xlxd ]
then
   echo ""
   echo "It looks like you have already compiled XLXD. If you want to install/complile xlxd again, delete the directory '/root/reflector-install-files/xlxd' and run this script again. "
   exit 0
else
   echo "Downloading and compiling xlxd... "
   echo "------------------------------------------------------------------------------"
   cd $XLXINSTDIR
   git clone $XLXDREPO
   cd $XLXINSTDIR/xlxd/src
   make clean
   make
   make install
fi
if [ -e $XLXINSTDIR/xlxd/src/xlxd ]
then
   echo ""
   echo ""
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
echo "Getting the DMRID.dat file... "
echo "------------------------------------------------------------------------------"
wget -O /xlxd/dmrid.dat $DMRIDURL
echo "------------------------------------------------------------------------------"
echo "Copying web dashboard files and updating init script... "
cp -R $XLXINSTDIR/xlxd/dashboard/* /var/www/xlxd/
cp $XLXINSTDIR/xlxd/scripts/xlxd /etc/init.d/xlxd
sed -i "s/XLX999 192.168.1.240 127.0.0.1/$XRFNUM $LOCAL_IP 127.0.0.1/g" /etc/init.d/xlxd
update-rc.d xlxd defaults
# Delaying startup time
mv /etc/rc3.d/S01xlxd /etc/rc3.d/S10xlxd
echo "Updating XLXD Config file... "
XLXCONFIG=/var/www/xlxd/pgs/config.inc.php
sed -i "s/your_email/$EMAIL/g" $XLXCONFIG
sed -i "s/LX1IQ/$CALLSIGN/g" $XLXCONFIG
sed -i "s/http:\/\/your_dashboard/http:\/\/$XLXDOMAIN/g" $XLXCONFIG
sed -i "s/\/tmp\/callinghome.php/\/xlxd\/callinghome.php/g" $XLXCONFIG
echo "Copying directives and reloading apache... "
cp $DIRDIR/templates/apache.tbd.conf /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/apache.tbd/$XLXDOMAIN/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
sed -i "s/ysf-xlxd/xlxd/g" /etc/apache2/sites-available/$XLXDOMAIN.conf
chown -R www-data:www-data /var/www/xlxd/
chown -R www-data:www-data /xlxd/
a2ensite $XLXDOMAIN
service xlxd start
systemctl restart apache2
echo "------------------------------------------------------------------------------"
echo ""
echo ""
echo "******************************************************************************"
echo ""
echo ""
echo "XLXD is finished installing and ready to be used. Please read the following..."
echo ""
echo ""
echo "******************************************************************************"
echo ""
echo " For Public Reflectors: "
echo "If your XLX number is not already taken, enabling callinghome is all you need to do  "
echo "for your reflector to be added to all the host files automatically. It does take     "
echo "about an hour for the change to reflect, if your reflector is accessible and working."
echo "Once activated, the callinghome hash to backup will be /xlxd/callinghome.php. "
echo "More Information: $INFREF"
echo ""
echo ""
echo " For test/private Reflectors: "
echo "If you are using this reflector as a test or for offline access you will  "
echo "need to configure the host files of the devices connecting to this server."
echo "There are many online tutorials on 'Editing pi-star host files'.          "
echo ""
echo ""
echo "          Your $XRFNUM dashboad should now be accessible...            "
echo "                http://$XLXDOMAIN                                      "
echo ""
echo ""
echo "You can make further customizations to the main config file $XLXCONFIG."
echo "Be sure to thank the creators of xlxd for the ability to spin up          "
echo "your very own D-Star reflector.                                           "
echo ""
echo "------------------------------------------------------------------------------"
