# xlxd-debian-installer
This script simply runs through the official install instructions found [HERE](https://github.com/LX3JL/xlxd). The script will install XLX along with setting up the web dashboard to view real-time activity. After installing this you will have a private or public D-Star, DMR, and YSF XLX Reflector.

At the start of 2020 a new version of XLX was released that allows for native C4FM connections. This means it's even simpler to run a multi-mode reflector. XLX now natively supports DMR, D-Star, and C4FM. C4FM and DMR do not require any transcoding hardware (AMBE) to work together. If you plan on using D-Star with any of the other modes, you will need hardware AMBE chips.


### To Install:
1. Have a fresh Debian 9.x computer ready and up to date.
2. Have both a FQDN and 3 digit XLX number in mind before beginning.
3. 
```sh
git clone https://github.com/n5amd/xlxd-debian-installer
cd xlxd-debian-installer
./xlxd-debian-installer
```
## How to find what reflectors are available
Find a current active reflector dashboard, for example, https://xlx.n5amd.com/index.php?show=reflectors and you will see the gaps in reflector numbers in the list. Those reflector numbers not listed are available. 

### To interact with xlxd after installation:
```sh
systemctl start|stop|status|restart xlxd
```
 - Installs to /xlxd
 - Logs are in /var/log/messages and *'systemctl status xlxd'*
 - Main config file is /var/www/xlxd/pgs/config.inc.php
 - Be sure to restart xlxd after each config change *'systemctl restart xlxd'*

**For more information, please visit:**

https://n5amd.com/digital-radio-how-tos/create-xlx-xrf-d-star-reflector/
