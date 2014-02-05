###  (c) Marcellus Siegburg, 2013, License: GPL
class mysql {
  case $operatingsystem {
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
  $user = 'user'
  $password = 'passwort'
  $school_id = 1
  $school_name = 'school'
  $school_mail_suffix = 'localhost'
  $minister_id = 1
  $minister_matrikel_number = '0'
  $minister_email = 'vagrant@localhost'
  $minister_familyname = 'Mustermann'
  $minister_name = 'Max'
  $minister_password = 'foobar'
  $minister_password_enc = "ghc -i/home/vagrant/tool/db/src Operate.Crypt -e 'encrypt \"${minister_password}\"'"
  package { 'mysql-server':
    name => "mysql-server",
    ensure => latest,
  }

  package { $mysqlclient:
    ensure => latest,
  }

  service { 'mysql':
    name => $mysqlservice,
    ensure => running,
    require => Package["mysql-server"],
  }

  exec { 'Create Database':
    command => "echo 'GRANT ALL ON autoan.* TO \"${user}\"@\"localhost\" IDENTIFIED BY \"${password}\"; CREATE DATABASE autoan;' | mysql -u root",
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
    command => "mysql -u ${user} -p${password} autoan < /home/vagrant/TABLES",
    user => "root",
    require => [ Service["mysql"],
                 Class["autotool::tool"],
                 Exec["Prepare TABLES file"],
                 Exec["Create Database"] ],
    unless => "echo 'use autoan; show tables;' | mysql -u root | grep ^aufgabe\$",
  }

  exec { 'Insert school':
    command => "echo \"use autoan; insert into schule (UNr, name, mail_suffix) values (${school_id}, '${school_name}', '${school_mail_suffix}');\" | mysql -u ${user} -p${password}",
    user => root,
    require => Exec["Create Tables"],
    unless => "echo 'use autoan; select * from schule;' | mysql -u root | grep '${school_name}'",
  }

  exec { 'Insert student':
    command => "echo \"use autoan; insert into student (SNr, MNr, Email, Name, Vorname, Status, UNr, Passwort) values (${minister_id}, '${minister_matrikel_number}', '${minister_email}', '${minister_familyname}', '${minister_name}', 'aktiv', '${school_id}', '\"\$(${minister_password_enc})\"');\" | mysql -u ${user} -p${password}",
    user => root,
    require => Exec["Create Tables"],
    unless => "echo 'use autoan; select * from student;' | mysql -u root | grep '${minister_familyname}'",
  }

  exec { 'Insert minister':
    command => "echo 'use autoan; insert into minister (SNr) values (${minister_id});' | mysql -u ${user} -p${password}",
    user => root,
    require => Exec["Create Tables"],
    unless => "echo 'use autoan; select * from minister;' | mysql -u root | grep '${minister_id}'",
  }

  exec { 'Insert direktor':
    command => "echo 'use autoan; insert into direktor (SNr, UNr) values (${minister_id},${school_id});' | mysql -u ${user} -p${password}",
    user => root,
    require => Exec["Create Tables"],
    unless => "echo 'use autoan; select * from direktor;' | mysql -u root | grep '${minister_id}'",
  }
}