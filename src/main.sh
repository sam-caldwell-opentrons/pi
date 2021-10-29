#!/bin/bash -e
# Raspberry Probe Image Builder
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#
export PAYLOAD_DIR=/mnt/usr/local/probe

success(){
  echo "[OK]: $1"
}

message(){
  echo "[__]: $1"
}

error(){
  echo "[XX]: Error(fatal): $1"
  exit 1
}

enable_ld_preload(){
  message "revert ld.so.preload fix"
  sed -i 's/^#//g' /mnt/etc/ld.so.preload
  success "ld preload: enabled"
}

disable_ld_preload(){
  message "ld.so.preload fix"
  sed -i 's/^/#/g' /mnt/etc/ld.so.preload
  success "ld preload: disabled"
}

install_payload(){
  echo "install payload scripts to raspberrypi image"
  mkdir "${PAYLOAD_DIR}"
  cp -rfvp /build/payload/* "${PAYLOAD_DIR}/"
  echo "export PROBE_VERSION=$(cat /build/VERSION.txt)" > /mnt/etc/profile.d/version.sh
  echo "Payload is installed to '${PAYLOAD_DIR}'"
}

map_disk_image_to_loop_devices(){
  message "Map our disks (image partitions) to loop devices"
  kpartx -av base.img
  fdisk -l /dev/mapper/loop0p1 || error "/dev/mapper/loop0p1 not mapped"
  fdisk -l /dev/mapper/loop0p2 || error "/dev/mapper/loop0p2 not mapped"
  success "Disk image mapped to loop devices."
}

mount_disks_and_devices(){
  message "mount our disks"
  mount -o rw /dev/mapper/loop0p2  /mnt || error "Failed to mount /mnt"
  mount -o rw /dev/mapper/loop0p1 /mnt/boot || error "Failed to mount /boot"
  success "disks mounted"
  message "binding devices"
  mount --bind /dev /mnt/dev/ || error "Failed to bind /dev"
  mount --bind /sys /mnt/sys/ || error "Failed to bind /sys"
  mount --bind /proc /mnt/proc/ || error "Failed to bind /proc"
  mount --bind /dev/pts /mnt/dev/pts || error "Failed to bind /dev/pts"
  success "device bind complete"
}

repair_and_resize_fs(){
  message "Repair and resize"
  e2fsck -f /dev/mapper/loop0p2 || error "root partition failed repair"
  resize2fs /dev/mapper/loop0p2 || error "root partition failed resize"
  success "Root partition checked, repaired and resized."
}

reset_loop_devices(){
  message "Ensure loop devices are clear"
  # shellcheck disable=SC2227
  find /dev/ -name "loop[0-9]" -exec losetup -d {} &> /dev/null \;
  find /dev/ -name "loop[0-9]" -exec kpartx -d {} \;
  success "loop devices cleared."
}

unmount_everything(){
  message "unmount everything from raspberrypi image."
  sync
  umount /mnt/{dev/pts,dev,sys,proc,boot,tmp,var/tmp,} || {
    error "unmount failed"
  }
  success "everything unmounted successfully."
}

pad_image_file(){
  message "Pad the image file."
  dd if=/dev/zero bs=1M count=8192 >> base.img || error "padding failed."
  success "Image file padded...resizing..."
  qemu-img resize -f raw base.img +6G || error "image resize failed."
  fdisk -l base.img | tail -n2
  success "padding and resize complete"
}

configure_image(){
  message "chroot to raspbian environment and configure things."
  chroot /mnt /bin/bash -c "/usr/local/probe/setup.sh" || \
    error "update_image failed"
  sync
  success "image updated/configured."
}

deliver_artifact(){
  message "deliver artifact to /output"
  ls -lah /build/base.img
  shasum -a 256 /build/base.img
  cp /build/base.img /output/raspberry-probe.img
  sync
  ls -lah /output/raspberry-probe.img
  shasum -a 256 /output/raspberry-probe.img
  success "successfully delivered artifact to /output"
}

main(){
  message "main(): starting image builder"
  reset_loop_devices || error "reset_loop_devices() failed"
  pad_image_file || error "pad_image_file() failed"
  map_disk_image_to_loop_devices || error "map_disk_image_to_loop_devices() failed"
  repair_and_resize_fs || error "repair_and_resize_disks() failed."
  mount_disks_and_devices || error "mount_disks_and_devices() failed."
  disable_ld_preload
  install_payload || error "install_payload() failed."
  configure_image || error "update_image() failed."
  mv /mnt/kernel.version /build/ || error "kernel.version file not exposed."
  enable_ld_preload || error "enable_ld_preload() failed."
  unmount_everything || error "unmount_everything() failed."
  reset_loop_devices || error "reset_loop_devices() failed."
  deliver_artifact || error "deliver_artifact() failed."
  cat /build/kernel.version || error "kernel.version file not passed back."
  success "main(): terminating without error"
}

main