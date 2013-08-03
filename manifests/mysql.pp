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

  exec { 'Create Database':
    command => "echo 'GRANT ALL ON autoan.* TO \"user\"@\"localhost\" IDENTIFIED BY \"passwort\"; CREATE DATABASE autoan;' | mysql -u root",
    user => "root",
    require => [ Service["mysql"],
                 Class["autotool::tool"] ],
    unless => "echo 'show databases;' | mysql -u root | grep ^autoan\$",
  }

  exec { 'Prepare TABLES file':
    command => "sed \"s/TYPE/ENGINE/\" /home/vagrant/tool/TABLES > /home/vagrant/TABLES",
    user => "vagrant",
    require => Class["autotool::tool"],
    unless => "test -f /home/vagrant/TABLES",
  }

  exec { 'Create Tables':
    command => "mysql -u user -ppasswort autoan < /home/vagrant/TABLES",
    user => "root",
    require => [ Service["mysql"],
                 Class["autotool::tool"],
                 Exec["Prepare TABLES file"],
                 Exec["Create Database"] ],
    unless => "echo 'use autoan; show tables;' | mysql -u root | grep ^aufgabe\$",
  }
}
