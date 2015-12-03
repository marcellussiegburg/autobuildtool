###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class mysql ($mysqlclient, $mysqlserver, $mysqlservice) {
  package { $mysqlserver:
    ensure => latest,
  }

  package { $mysqlclient:
    ensure => latest,
  }

  service { $mysqlservice:
    ensure  => running,
    enable  => true,
    require => Package[$mysqlserver],
  }
}
