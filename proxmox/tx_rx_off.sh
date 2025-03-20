#!/bin/bash

# to fix Intel(R) PRO/1000 Network Connection issue like
# journalctl --since "2 days ago" | grep -i "hardware unit hang"
# add into crontab like 
# @reboot /root/bin/tx_rx_off.sh

/usr/sbin/ethtool -K eno1 tx off rx off


