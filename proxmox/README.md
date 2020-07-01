```
apt install git mc python-pip -y && pip install ansible
git clone https://github.com/familyman-131/ansible.git
cd ansible/proxmox/ 
```  
you can ajust folloving variables in proxmox.yml  
```
      vm_ipv4_address: 192.168.23.100
      vm_network: 192.168.23.0/24
      vm_ext_port: 3389
      vm_int_port: 3389
      vmbr_name: vmbr23
      vmbr_ipv4_address: 192.168.23.1
      vmbr_ipv4_netmask: 255.255.255.0
```   
or just run  
`ansible-playbook proxmox.yml`

to add vmbr without ip addresses
```  
# device: eno1
allow-hotplug eno1
auto  eno1
iface eno1 inet manual
auto vmbr33
iface vmbr33 inet manual
        bridge_ports eno1
        bridge_stp off
        bridge_fd 0
```  
to add real HDD to VM
see "product" "serial"  
`lshw -class disk -class storage`  
check it with /dev/"disk"  
`ls -l /dev/disk/by-id/ata\sata-"product"`  
add it to VM  
`qm set 100 -virtio1 /dev/disk/by-id/ata\sata-"product"`  
check it in VM.conf  
or manually add   
`sfdisk -l -s - shows size in Kb`  
and make row like this  
`virtio1: /dev/disk/by-id/ata-WDC_WD5000AAKX-603CA0_WD-WMAYUV041558,size=488386584K`  
or add one partition like https://mikeeverhart.net/2015/08/proxmox-share-host-hard-drive-with-vm-guest/

Bug 1377155 - "HID Button over Interrupt Driver" not working properly in windows10 and win2016
Device manager -> Right click HID Button over Interrupt Driver -> Click Update Driver Software...
Click "Browse my computer for driver software"
Click "Let me pick from a list of device drivers on my computer"
Select "Generic Bus" and click Next.
**OR**
According to MS the solution is to remove the device:
1. Uninstall the existed driver package for this device, if can check delete button, please check it too.
2. Download the PsTools from
https://technet.microsoft.com/en-us/sysinternals/pstools.aspx
3. Unzip PsTools, and locate the folder of PsTools, then input in CMD (Run as Administrator):  
`psexec -s -i regedit.exe`  
4. Delete subkey ACPI0010 under HKLM\SYSTEM\DriverDataBase\DriverPackage\hiinterrupt.inf_x86_<some instance ID>\Descriptors\ACPI0010
And delete subkey "bidinterrupt.inf" under HKLM\SYSTEM\DriverDataBase\DeviceIds\ACPI\ACPI0010
5. Rescan device to see the effect.

https://pve.proxmox.com/wiki/HTTPS_Certificate_Configuration_(Version_4.x_and_newer)  
`./acme.sh --issue --standalone --force --keypath /etc/pve/local/pve-ssl.key --fullchainpath /etc/pve/local/pve-ssl.pem --capath /etc/pve/pve-root-ca.pem --reloadcmd "systemctl restart pveproxy" -d DOMAIN`  
(local is symlink, so may be you need fullpath to /etc/pve/nodes/NODE_NAME)
crontab  
`"/root/.acme.sh"/acme.sh --cron --force --home "/root/.acme.sh"`  
normally result must be as:  
```
[Sun Mar 26 19:10:38 EEST 2017] Your cert is in  /root/.acme.sh/prox1.it-man.pro/prox1.it-man.pro.cer
[Sun Mar 26 19:10:38 EEST 2017] Your cert key is in  /root/.acme.sh/prox1.it-man.pro/prox1.it-man.pro.key
[Sun Mar 26 19:10:38 EEST 2017] The intermediate CA cert is in  /root/.acme.sh/prox1.it-man.pro/ca.cer
[Sun Mar 26 19:10:38 EEST 2017] And the full chain certs is there:  /root/.acme.sh/prox1.it-man.pro/fullchain.cer
[Sun Mar 26 19:10:38 EEST 2017] Installing CA to:/etc/pve/pve-root-ca.pem
[Sun Mar 26 19:10:38 EEST 2017] Installing key to:/etc/pve/local/pve-ssl.key
[Sun Mar 26 19:10:38 EEST 2017] Installing full chain to:/etc/pve/local/pve-ssl.pem
[Sun Mar 26 19:10:38 EEST 2017] Run reload cmd: systemctl restart pveproxy
[Sun Mar 26 19:10:40 EEST 2017] Reload success
```
alternate https-gen method   
```
aptitude install certbot
certbot certonly --standalone --agree-tos -m user@email -d domain
rm -rf /etc/pve/local/pve-ssl.pem  
rm -rf /etc/pve/local/pve-ssl.key  
rm -rf /etc/pve/pve-root-ca.pem  
cp /etc/letsencrypt/live/domain/fullchain.pem  /etc/pve/local/pve-ssl.pem  
cp /etc/letsencrypt/live/domain/privkey.pem /etc/pve/local/pve-ssl.key  
cp /etc/letsencrypt/live/domain/chain.pem /etc/pve/pve-root-ca.pem 
service pveproxy restart
service pvedaemon restart
```
crontab this like: @monthly /root/bin/cert-renew.sh
```
#!/bin/bash
/usr/bin/certbot renew >> /var/log/letsencrypt/letsencrypt.log
rm -rf /etc/pve/local/pve-ssl.pem
rm -rf /etc/pve/local/pve-ssl.key
rm -rf /etc/pve/pve-root-ca.pem
cp /etc/letsencrypt/live/domain/fullchain.pem  /etc/pve/local/pve-ssl.pem
cp /etc/letsencrypt/live/domain/privkey.pem /etc/pve/local/pve-ssl.key
cp /etc/letsencrypt/live/domain/chain.pem /etc/pve/pve-root-ca.pem
service pveproxy restart
service pvedaemon restart
```

it's possible to use subnet and separate IP simultaneously as described here https://community.hetzner.com/tutorials/install-and-configure-proxmox_ve/ru?title=Proxmox_VE/ru

main prox IP      
```
IP: 22.12.84.58   
Gateway: 22.12.84.1     
Netmask: 255.255.255.192      
```
additional IP with MAC
```
Gateway: 22.12.84.1     
Netmask: 255.255.255.192      
Broadcast: 22.12.84.63  
Separate MAC: 00:60:56:50:C3:0F     
```
additional subnet 85.9.169.192/28
```
85.9.169.192	prox	      
85.9.169.193	vm    
```

prox.interfaces
```
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

iface lo inet6 loopback

auto eno1

# for separate IP with MAC
iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
        address 22.12.84.58
        netmask 255.255.255.192
        gateway 22.12.84.1
        pointopoint 22.12.84.1
    dns-nameservers 8.8.4.4 8.8.8.8
    bridge_ports eno1
    bridge_stp off
    bridge_fd 0

# for subnet
auto vmbr1
iface vmbr1 inet static
  address 85.9.169.192
  netmask 255.255.255.240
  bridge_ports none
  bridge_stp off
  bridge_fd 0
```

guest.interfaces for subnet for example eth0
```
auto  eth0
iface eth0 inet static
  address   85.9.169.193
  netmask   255.255.255.240
  gateway   85.9.169.192
```
guest.interfaces for  separate IP with MAC for example eth0   
don't forget assign to VM MAC, generated by hetzner!  
can leave DHCP setup if lazy  
```
auto  eth0
iface eth0 inet static
       address   22.12.84.36
       netmask   255.255.255.192
       gateway   22.12.84.1
```

