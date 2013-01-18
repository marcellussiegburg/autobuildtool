###  (c) Marcellus Siegburg, 2013, License: GPL
class mysql {
  package { 'mysql-server':
    name => "mysql-server",
    ensure => latest,
  }

  package { 'libmysqlclient':
    name => "libmysqlclient-dev",
    ensure => latest,
  }

  service { 'mysql':
    name => mysql,
    ensure => running,
    require => Package["mysql-server"],
  }
}
