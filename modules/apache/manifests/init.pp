###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class apache ($apache, $apache_user) {
  package { $apache:
    ensure => latest,
  }

  exec { 'a2enmod cgi':
    user    => 'root',
    require => Package[$apache],
    notify  => Service[$apache],
  }

  service { $apache:
    ensure  => running,
    enable  => true,
    require => Package[$apache],
  }
}
