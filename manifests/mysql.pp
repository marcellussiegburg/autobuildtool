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

  exec { 'Insert uni':
    command => "echo \"use autoan; insert into schule (UNr, name, mail_suffix) values (0, 'testing', '');\" | mysql -u user -ppasswort",
    user => root,
    require => Exec["Create Tables"],
    unless => "echo 'use autoan; select * from schule;' | mysql -u root | grep testing",
  }

  exec { 'Insert student':
    command => "echo \"use autoan; insert into student (SNr, MNr, Name, Vorname, Status, UNr) values (0, '0', 'Mustermann', 'Max', 'aktiv', '0');\" | mysql -u user -ppasswort",
    user => root,
    require => Exec["Create Tables"],
    unless => "echo 'use autoan; select * from student;' | mysql -u root | grep Mustermann",
  }

  exec { 'Insert direktor':
    command => "echo 'use autoan; insert into direktor values (1,0);' | mysql -u user -ppasswort",
    user => root,
    require => Exec["Create Tables"],
    unless => "echo 'use autoan; select * from direktor;' | mysql -u root | grep 0",
  }
}
