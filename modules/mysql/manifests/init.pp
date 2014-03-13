###  (c) Marcellus Siegburg, 2014, License: GPL
class mysql {
  case $::operatingsystem {
    ubuntu: {
      $mysqlclient = 'libmysqlclient-dev'
      $mysqlservice = 'mysql'
    }
    CentOS: {
      $mysqlclient = ['mysql-devel', 'mysql-libs']
      $mysqlservice = 'mysqld'
    }
    default: {
      fail('Unrecognized operating system for mysql')
    }
  }
  package { 'mysql-server':
    ensure => latest,
  }

  package { $mysqlclient:
    ensure => latest,
  }

  service { $mysqlservice:
    ensure  => running,
    enable  => true,
    require => Package['mysql-server'],
  }
}
