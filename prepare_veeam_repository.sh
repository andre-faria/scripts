#!/bin/bash
##################################################
# SCRIPT NAME    : prepare_veeam_repository.sh
# DESCRIPTION    : Script to deploy new Veeam repositories 
# AUTHOR         : André M. Faria
# EMAIL          : yamash.ox@gmail.com
# CREATED        : 2023-12-07
# MODIFIED       :
##################################################

# Install dependencies
sudo apt install -f -y nfs-kernel-server mlocate libc6-dev-i386 perl perl-doc openssh-server

# Following modules are a prereq for imutable repositories
sudo cpan constant Carp Cwd Data::Dumper Encode Encode::Alias Encode::Config Encode::Encoding Encode::Mime::Name Exporter Exporter::Heavy File:::Path File::Spec File::Spec::Unix File::temp List::Util Scalar::Util SOAP::lite Socket Storable threads

# Disk rescan
for i in $ $(ls /sys/class/scsi_host/); do echo "- - -" > /sys/class/scsi_host/$i/scan; done

# Mount point creation
mkdir -p /veeam/repository01

# Erase MBR and GPT information from disks
for i in $(ls /dev/sd* | grep sd[b-z]$); do wipefs --all --force $i; done

# Create new partitions
for i in $(ls /dev/sd* | grep sd[b-z]$); do parted -a optimal $i mklabel gpt && parted -a optimal $i mkpart primary 0% 100%; done

# Making system aware of partition modifications
partprobe

# LVM Configuration
sudo pvcreate $(ls /dev/sd* | grep sd[b-z]1$)
sudo vgcreate veeam-vg $(ls /dev/sd* | grep sd[b-z]1$)
sudo lvcreate -l 100%FREE -n repository01 veeam-vg

# Formatting repository in XFS, Necessary for Veeam Fast Clone
sudo mkfs.xfs /dev/veeam-vg/repository01

# Extract LVM UUID and
echo $(sudo blkid | grep veeam--vg-repository01 | cut -d ' ' -f 2 | sed 's/"//g') "/veeam/repository01 xfs defaults 0 0" >> /etc/fstab
mount /veeam/repository01

# Backup user creation
groupadd backup-group
useradd backup-operator --create-home --no-user-group -g backup-group -G sudo --shell /bin/bash
usermod --password $(echo '<Password>' | openssl passwd -1 -stdin) backup-operator

# Setting permissions
sudo chown -R root:root /veeam
sudo chmod -R 755 /veeam
sudo chown -R backup-operator:backup-group /veeam/repository01

# NFS Configuration
#echo "/nfs/repository 10.7.7.0/24(rw,sync,no_subtree_check)" >> /etc/exports
#sudo exportfs -a
#sudo systemctl restart nfs-kernel-server

# Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sudo sysctl -p
cat /proc/sys/net/ipv6/conf/all/disable_ipv6

# Execute the following command after the Veeam Transport installation
# gpasswd -d backup-operator sudo

# usermod -G sudo,backup-operator backup-operator
