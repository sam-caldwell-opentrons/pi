#!/bin/bash -ex
# Raspberry Probe Image Builder (setup.sh)
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#
success(){
  echo "..[OK]: $1"
}

message(){
  echo "..[__]: $1"
}

error(){
  echo "..[XX]: Error(fatal): $1"
  exit 1
}

fix_time(){
  message "Fix timezone data so we stay noninteractive."
  truncate -s0 /tmp/tzdata.cfg
  echo "tzdata tzdata/Areas select Etc" >> /tmp/tzdata.cfg
  echo "tzdata tzdata/Zones/Europe select UTC" >> /tmp/tzdata.cfg
  debconf-set-selections /tmp/tzdata.cfg
  rm -f /etc/timezone /etc/localtime
  apt-get install -y tzdata
  dpkg-reconfigure tzdata
  rm /tmp/tzdata.cfg || true
  success "fix_time() completed"
}

make_non_interactive(){
    message "make the environment non-interactive"
    export DEBIAN_FRONTEND=noninteractive
    export DEBCONF_NONINTERACTIVE_SEEN=true
    {
    echo "export DEBIAN_FRONTEND=noninteractive"
    echo "export DEBCONF_NONINTERACTIVE_SEEN=true"
    } >> /etc/profile.d/non-interactive.sh
    success "make_non_interactive() done"
}

clean_apt_cache(){
  message "remove apt cache"
  rm -rf /var/cache/apt/
  success "clean_apt_cache() done"
}

setup_ram_disks(){
  message "create ram disks"
    {
      echo "tmpfs /tmp tmpfs noexec,nodev,noatime,nosuid,size=100M 0 0"
      echo "tmpfs /var/tmp tmpfs noexec,nodev,noatime,nosuid,size=50M 0 0"
    } >> /etc/fstab
    mount /tmp
    mount /var/tmp
    success "setup_ram_disks() done"
}

remove_unwanted_packages(){
  message "remove unwanted packages (e.g. openssh server, sftp)"
  apt-get purge openssh-server* openssh-sftp* ssh ssh-import-id xauth xkb* man-db -y
  apt-get autoremove -y && apt-get autoclean -y
  success "remove_unwanted_packages() done"
}

install_firewall(){
  message "Install UFW (uncomplicated firewall)"
  update-alternatives --set iptables /usr/sbin/iptables-legacy
  apt-get install --no-install-recommends -y ufw
  success "install_firewall() done"
}

update_system(){
  message "update the system packages"
  sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list.d/raspi.list
  sed -i 's/^#deb-src/deb-src/' /etc/apt/sources.list
  apt-get update -y --fix-missing --allow-releaseinfo-change
  apt-get upgrade -y
  success "update_system() done"
}
clean_up(){
  message "clean-up after ourselves."
  umount /var/cache/apt
  sed -i 's/tmpfs \/var\/cache\/apt/#tmpfs \/var\/cache\/apt/' /etc/fstab
  success "clean_up() done"
}

main(){
  message "start the configuration process"
  make_non_interactive
  clean_apt_cache
  setup_ram_disks
  fix_time
  remove_unwanted_packages
  #update_system
	#ToDo: install other things
	sync
	success "complete the configuration process"
	exit
}

main