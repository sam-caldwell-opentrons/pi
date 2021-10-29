#!/bin/bash -e

init(){
  mount -o noexec,nodev,noatime,nosuid,size=1G -t tmpfs none /var/cache/apt
  mount /var/cache/apt
  mkdir -p /var/cache/apt/archives/partial
  chown -R _apt:root /var/cache/apt/archives/partial
  chmod 0700 /var/cache/apt/archives/partial
  touch /var/cache/apt/archives/lock
  chmod 0640 /var/cache/apt/archives/lock
}


main(){
  init
  apt-get update -y
  apt-get upgrade -y
}
main