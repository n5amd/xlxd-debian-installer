# xlxd-debian-installer
This script simply runs through the official install instructions found [HERE](https://github.com/LX3JL/xlxd). It will install your own D-Star reflector along with setting up the web dashboards to view real-time activity. It can be used to install a private or a public D-Star XRF Reflector online or offline.


### To Install:
1. Have a fresh Debian 9.x computer ready and up to date.
2. Have both a FQDN and XRF # in mind before beginning.
3. 
```sh
git clone https://github.com/n5amd/xlxd-debian-installer
cd xlxd-debian-installer
./xlxd-debian-installer
```

### To interact with xlxd after installation:
```sh
systemctl start|stop|status|restart xlxd
```
 - Installs to /xlxd
 - Logs are in /var/log/messages and *'systemctl status xlxd'*
 - Main config file is /var/www/xlxd/pgs/config.inc.php
 - Be sure to restart xlxd after each config change *'systemctl restart xlxd'*

**For more information, please visit:**
https://sadigitalradio.com/digital-radio-how-tos/create-xlx-xrf-d-star-reflector/
