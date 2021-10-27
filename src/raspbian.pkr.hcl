locals {
  raspbian_base_url        = "https://downloads.raspberrypi.org/raspbian/images"
  raspbian_base_image      = "${local.raspbian_base_url}/raspbian-2019-07-12/2019-07-10-raspbian-buster.zip"
  raspbian_base_image_hash = "${local.raspbian_base_url}/raspbian-2019-07-12/2019-07-10-raspbian-buster.zip.sha256"
}

source "arm" "base_image_raspbery_pi" {
  file_checksum_type           = "sha256"
  file_checksum_url            = local.raspbian_base_image_hash
  file_target_extension        = "zip"
  file_urls                    = [local.raspbian_base_image]
  image_build_method           = "reuse"
  image_chroot_env             = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  image_partitions {
    filesystem   = "vfat"
    mountpoint   = "/boot"
    name         = "boot"
    size         = "256M"
    start_sector = "8192"
    type         = "c"
  }
  image_partitions {
    filesystem   = "ext3"
    mountpoint   = "/"
    name         = "root"
    size         = "2G"
    start_sector = "532480"
    type         = "83"
  }
  image_path                   = "build/raspberry-pi.img"
  image_size                   = "2G"
  image_type                   = "dos"
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
}

build {
  sources = ["source.arm.base_image_raspbery_pi"]
  provisioner "shell" {
    inline = ["touch /tmp/test"]
  }
}
