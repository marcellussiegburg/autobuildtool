###  (c) Marcellus Siegburg, 2013, License: GPL
class apache {
  case $::operatingsystem {
    ubuntu: {
      $apache = 'apache2'
      $cgi_bin = '/usr/lib/cgi-bin'
    }
    CentOS: {
      $apache = 'httpd'
      $cgi_bin = '/var/www/cgi-bin'
    }
    default: { fail('Unrecognized operating system for webserver') }
  }

  package { 'apache2':
    ensure => latest,
    name   => $apache,
  }

  service { 'apache2':
    ensure  => running,
    name    => $apache,
    require => Package['apache2'],
  }

  file { 'autotool.cgi':
    ensure  => file,
    name    => "${cgi_bin}/autotool.cgi",
    require =>
      [ Class['autotool::tool'],
        Package['apache2'] ],
    source  => '/home/vagrant/.cabal/bin/autotool.cgi',
  }

  file { 'Super.cgi':
    ensure  => file,
    name    => "${cgi_bin}/Super.cgi",
    require =>
      [ Class['autotool::tool'],
        Package['apache2'] ],
    source  => '/home/vagrant/.cabal/bin/autotool-Super',
  }
}
