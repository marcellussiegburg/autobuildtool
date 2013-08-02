###  (c) Marcellus Siegburg, 2013, License: GPL
class apache {
  case $operatingsystem {
    ubuntu: { $apache = "apache2" }
    default: { fail("Unrecognized operating system for webserver") }
  }

  package { 'apache2':
    name => $apache,
    ensure => latest,
  }

  service { 'apache2':
    name => $apache,
    ensure => running,
    require => Package["apache2"],
  }

  file { 'autotool.cgi':
    name => "/usr/lib/cgi-bin/autotool.cgi",
    ensure => file,
    require => [ Class["autotool"],
                 Package["apache2"] ],
    source => "/home/vagrant/.cabal/bin/autotool.cgi",
  }

  file { 'Super.cgi':
    name => "/usr/lib/cgi-bin/Super.cgi",
    ensure => file,
    require => [ Class["autotool"],
                 Package["apache2"] ],
    source => "/home/vagrant/.cabal/bin/autotool-Super",
  }
}
