#!/bin/bash -e
# Raspberry Probe Image Builder
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#

error(){
  echo "$1"
  exit 1
}

fix_time(){
  echo "Fix timezone data so we stay noninteractive."
  truncate -s0 /tmp/tzdata.cfg
  echo "tzdata tzdata/Areas select Etc" >> /tmp/tzdata.cfg
  echo "tzdata tzdata/Zones/Europe select UTC" >> /tmp/tzdata.cfg
  debconf-set-selections /tmp/tzdata.cfg
  rm -f /etc/timezone /etc/localtime
  apt-get install -y tzdata
  dpkg-reconfigure tzdata
  rm /tmp/tzdata.cfg || true
}

reset_loop_devices(){
  echo "Ensure loop devices are clear"
  # shellcheck disable=SC2227
  find /dev/ -name "loop[0-9]" -exec losetup -d {} &> /dev/null \;
  find /dev/ -name "loop[0-9]" -exec kpartx -d {} \;
}

download_image_file(){
echo "Download a base image and unzip the artifact"
wget https://downloads.raspberrypi.org/raspbian_lite_latest
unzip -p raspbian_lite_latest > base.img
}

pad_image_file(){
  echo "Pad the image file."
  dd if=/dev/zero bs=1M count=16384 >> base.img
  fdisk -l base.img | tail -n2
}

map_disk_image_to_loop_devices(){
  echo "Map our disks (image partitions) to loop devices"
  kpartx -av base.img
  fdisk -l /dev/mapper/loop0p1
  fdisk -l /dev/mapper/loop0p2
}

repair_and_resize_disks(){
  echo "Repair and resize"
  e2fsck -f /dev/mapper/loop0p2
  resize2fs /dev/mapper/loop0p2
}

mount_disks_and_devices(){
  echo "mount our disks"
  mount -o rw /dev/mapper/loop0p2  /mnt
  mount -o rw /dev/mapper/loop0p1 /mnt/boot
  echo "mount binds"
  mount --bind /dev /mnt/dev/
  mount --bind /sys /mnt/sys/
  mount --bind /proc /mnt/proc/
  mount --bind /dev/pts /mnt/dev/pts
}

disable_ld_preload(){
  echo "ld.so.preload fix"
  sed -i 's/^/#/g' /mnt/etc/ld.so.preload
}

update_image(){
echo "chroot to raspbian environment."
chroot /mnt /bin/bash
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  {
  echo "export DEBIAN_FRONTEND=noninteractive"
  echo "export DEBCONF_NONINTERACTIVE_SEEN=true"
  } >> /etc/profile.d/non-interactive.sh

  echo "remove apt cache"
  rm -rf /var/cache/apt/

  echo "create ram disks"
  {
    echo "tmpfs /tmp tmpfs noexec,nodev,noatime,nosuid,size=100M 0 0"
    echo "tmpfs /var/tmp tmpfs noexec,nodev,noatime,nosuid,size=50M 0 0"
  } >> /etc/fstab
  mount /tmp
  mount /var/tmp

  fix_time

  apt-get purge openssh-server* openssh-sftp* ssh ssh-import-id xauth xkb* man-db -y
  apt-get autoremove -y && apt-get autoclean -y

  update-alternatives --set iptables /usr/sbin/iptables-legacy
  apt-get install --no-install-recommends -y python3 python3-pip ufw

  sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list.d/raspi.list
  sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list
	apt-get update -y --fix-missing --allow-releaseinfo-change
	apt-get upgrade -y

	#ToDo: install other things

	#ToDo: cleanup
  umount /var/cache/apt
  sed -i 's/tmpfs \/var\/cache\/apt/#tmpfs \/var\/cache\/apt/' /etc/fstab
	exit
}
enable_ld_preload(){
  # revert ld.so.preload fix
  sed -i 's/^#//g' /mnt/etc/ld.so.preload
}
unmount_everything(){
  # unmount everything
  umount /mnt/{dev/pts,dev,sys,proc,boot,}
}
install_scripts(){
  echo "install scripts to raspberrypi image"
  cp -rfvp scripts/* /usr/local/bin/
}

main(){
  echo "main(): starting image builder"
  download_image_file || error "download_image_file() failed"
  reset_loop_devices || error "reset_loop_devices() failed"
  pad_image_file || error "pad_image_file() failed"
  map_disk_image_to_loop_devices || error "map_disk_image_to_loop_devices() failed"
  repair_and_resize_disks || error "repair_and_resize_disks() failed."
  mount_disks_and_devices || error "mount_disks_and_devices() failed."
  disable_ld_preload
  install_scripts || error "install_scripts() failed."
  update_image || error "update_image() failed."
  enable_ld_preload || error "enable_ld_preload() failed."
  unmount_everything || error "unmount_everything() failed."
  reset_loop_devices || error "reset_loop_devices() failed."
  echo "main(): terminating without error"
}
