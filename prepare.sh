#!/bin/bash
case $(facter osfamily) in
    Debian)
	wget -nv https://apt.puppetlabs.com/puppetlabs-release-$(facter lsbdistcodename).deb
	dpkg -iEG -D1 puppetlabs-release-$(facter lsbdistcodename).deb
	rm puppetlabs-release-$(facter lsbdistcodename).deb
	apt-get update -qq --fix-missing
	apt-get install -qq -y puppet ;;
    RedHat)
	yum update -y puppet ;;
    *)
	echo "Operating System Family not supported" >&2
	exit 1 ;;
esac
service puppet stop
exit 0