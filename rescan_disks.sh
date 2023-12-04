#!/bin/bash
for i in $ $(ls /sys/class/scsi_device/); do echo 1 | sudo tee /sys/class/scsi_device/$i/device/rescan; done
for i in $ $(ls /sys/class/scsi_host/); do echo "- - -" | sudo tee /sys/class/scsi_host/$i/scan; done
