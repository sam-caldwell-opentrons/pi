#!/bin/bash -ex
# Raspberry Probe Image Builder (setup.sh)
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#
error(){
  echo "Error(fatal): $1"
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

make_non_interactive(){
    export DEBIAN_FRONTEND=noninteractive
    export DEBCONF_NONINTERACTIVE_SEEN=true
    {
    echo "export DEBIAN_FRONTEND=noninteractive"
    echo "export DEBCONF_NONINTERACTIVE_SEEN=true"
    } >> /etc/profile.d/non-interactive.sh
}

clean_apt_cache(){
  echo "remove apt cache"
  rm -rf /var/cache/apt/
}

setup_ram_disks(){
  echo "create ram disks"
    {
      echo "tmpfs /tmp tmpfs noexec,nodev,noatime,nosuid,size=100M 0 0"
      echo "tmpfs /var/tmp tmpfs noexec,nodev,noatime,nosuid,size=50M 0 0"
    } >> /etc/fstab
    mount /tmp
    mount /var/tmp
}

remove_unwanted_packages(){
  echo "remove unwanted packages (e.g. openssh server, sftp)"
  apt-get purge openssh-server* openssh-sftp* ssh ssh-import-id xauth xkb* man-db -y
  apt-get autoremove -y && apt-get autoclean -y
}

install_firewall(){
  echo "Install UFW (uncomplicated firewall)"
  update-alternatives --set iptables /usr/sbin/iptables-legacy
  apt-get install --no-install-recommends -y ufw
}

update_system(){
  sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list.d/raspi.list
  sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list
  apt-get update -y --fix-missing --allow-releaseinfo-change
  apt-get upgrade -y
}
clean_up(){
  umount /var/cache/apt
  sed -i 's/tmpfs \/var\/cache\/apt/#tmpfs \/var\/cache\/apt/' /etc/fstab
}

main(){
  make_non_interactive
  clean_apt_cache
  setup_ram_disks
  fix_time
  remove_unwanted_packages
  update_system
	#ToDo: install other things
}

main