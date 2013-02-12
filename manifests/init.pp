###  (c) Marcellus Siegburg, 2013, License: GPL
Exec {
  path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/sbin/", "/usr/local/bin/" ],
  environment => "HOME=/home/vagrant",
  user => "vagrant",
  timeout => 0,
}

class init {
  include apache
  include mysql
  include haskell
  include git
  include autotool
  include emacs

  exec { 'apt-get update':
    command => "sudo /usr/bin/apt-get update --fix-missing",
    before => [ Class["apache"],
                Class["mysql"],
                Class["haskell"],
                Class["git"],
                Class["autotool"],
                Class["emacs"] ],
  }

  package { 'make':
    name => "make",
    ensure => latest,
    before => [ Class["haskell"],
                Class["autotool"] ],
  }

  file { '/home/vagrant':
    name => "/home/vagrant",
    ensure => directory,
    group => "vagrant",
    owner => "vagrant",
    recurse => true,
    before => [ Class["apache"],
                Class["mysql"],
                Class["haskell"],
                Class["git"],
                Class["autotool"] ],
  }
}

include init
