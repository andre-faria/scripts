#!/bin/bash
for i in $ $(ls /sys/class/scsi_device/); do echo 1 > /sys/class/scsi_device/$i/device/rescan; done
for i in $ $(ls /sys/class/scsi_device/); do sudo echo 1 > sudo tee /sys/class/scsi_device/$i/device/rescan; done
for i in $ $(ls /sys/class/scsi_host/); do echo "- - -" > /sys/class/scsi_host/$i/scan; done
for i in $(ls /sys/class/scsi_host); do echo -e "Scanning $i"; echo "- - -" > /sys/class/scsi_host/$i/scan; sleep 5; done
sudo echo "1" | sudo tee /sys/class/scsi_device/2\:0\:0\:0/device/rescan
