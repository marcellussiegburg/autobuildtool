#!/bin/bash
function swap {
    SIZE=$1
    if [ $# -lt 1 ] || [ $SIZE -le 0 ]
    then
	echo 'Remove Swapfile'
	sed -i '/\/root\/swapfile/d' /etc/fstab
    else
	swapoff /root/swapfilee 2> /dev/null
	echo 'Create Swapfile'
	dd if=/dev/zero of=/root/swapfile bs=1M count=$SIZE
	chmod 600 /root/swapfile
	mkswap /root/swapfile
	if ! grep --silent '/root/swapfile' /etc/fstab
	then
	    echo '/root/swapfile swap swap defaults 0 0' >> /etc/fstab
	fi
	swapon -a
    fi
    return 0
}

case $(facter osfamily) in
    Debian)
	wget -nv https://apt.puppetlabs.com/puppetlabs-release-$(facter lsbdistcodename).deb
	dpkg -iEG -D1 puppetlabs-release-$(facter lsbdistcodename).deb
	rm puppetlabs-release-$(facter lsbdistcodename).deb
	apt-get update -qq --fix-missing
	apt-get install -qq -y puppet ;;
    RedHat)
	yum install -y puppet-3.6.2
	yum update -y ca-certificates
        yum-config-manager --enable epel > /dev/null ;;
    *)
	echo "Operating System Family not supported" >&2
	exit 1 ;;
esac
swap $1
chown vagrant:vagrant /home/vagrant
service puppet stop
exit 0
