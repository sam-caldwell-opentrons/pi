#!/bin/bash -e
# Raspberry Probe Image Builder
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#
export PAYLOAD_DIR=/mnt/usr/local/probe

error(){
  echo "Error(fatal): $1"
  exit 1
}

download_image_file(){
  echo "Download a base image and unzip the artifact"
  wget https://downloads.raspberrypi.org/raspbian_lite_latest
  unzip -p raspbian_lite_latest > base.img
}

enable_ld_preload(){
  # revert ld.so.preload fix
  sed -i 's/^#//g' /mnt/etc/ld.so.preload
}

disable_ld_preload(){
  echo "ld.so.preload fix"
  sed -i 's/^/#/g' /mnt/etc/ld.so.preload
}

install_payload(){
  echo "install payload scripts to raspberrypi image"
  mkdir "${PAYLOAD_DIR}"
  cp -rfvp /build/payload/* "${PAYLOAD_DIR}/"
  echo "Payload is installed to '${PAYLOAD_DIR}'"
}

map_disk_image_to_loop_devices(){
  echo "Map our disks (image partitions) to loop devices"
  kpartx -av base.img
  fdisk -l /dev/mapper/loop0p1
  fdisk -l /dev/mapper/loop0p2
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

repair_and_resize_disks(){
  echo "Repair and resize"
  e2fsck -f /dev/mapper/loop0p2
  resize2fs /dev/mapper/loop0p2
}

reset_loop_devices(){
  echo "Ensure loop devices are clear"
  # shellcheck disable=SC2227
  find /dev/ -name "loop[0-9]" -exec losetup -d {} &> /dev/null \;
  find /dev/ -name "loop[0-9]" -exec kpartx -d {} \;
}

unmount_everything(){
  # unmount everything
  umount /mnt/{dev/pts,dev,sys,proc,boot,}
}

pad_image_file(){
  echo "Pad the image file."
  dd if=/dev/zero bs=1M count=16384 >> base.img
  fdisk -l base.img | tail -n2
}

update_image(){
  echo "chroot to raspbian environment."
  chroot /mnt /usr/local/payload/setup.sh
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
  install_payload || error "install_payload() failed."
  update_image || error "update_image() failed."
  enable_ld_preload || error "enable_ld_preload() failed."
  unmount_everything || error "unmount_everything() failed."
  reset_loop_devices || error "reset_loop_devices() failed."
  echo "main(): terminating without error"
}

main