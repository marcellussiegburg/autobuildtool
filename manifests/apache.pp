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
}
