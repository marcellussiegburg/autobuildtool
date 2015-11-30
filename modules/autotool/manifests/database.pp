###  (c) Marcellus Siegburg, 2014, License: GPL
class autotool::database ($school_name, $school_mail_suffix,
$minister_matrikel_number, $minister_email, $minister_familyname,
$minister_name, $minister_password, $db, $user, $password) {
  $school_id = 1
  $minister_id = 1
  $tool_path = $::autotool::autotool_path
  $hardwaremodel = inline_template("<%= %x{uname -i | tr -d '\n'} %>")
  $folder = "${hardwaremodel}-linux-ghc-${::haskell::ghc::version}"
  $package_db = "-package-db=/home/vagrant/tool/yesod/.cabal-sandbox/${folder}/"
  $minister_password_enc = "ghc ${package_db} -i${tool_path}/db/src Operate.Crypt -e 'encrypt \"${minister_password}\"'"

  exec { 'Create Database':
    command => "echo 'GRANT ALL ON ${db}.* TO \"${user}\"@\"localhost\" IDENTIFIED BY \"${password}\"; CREATE DATABASE ${db};' | mysql -u root",
    user    => 'root',
    unless  => "echo 'show databases;' | mysql -u root | grep ^${db}\$",
  }

  exec { 'Create Tables':
    command => "mysql -u ${user} -p${password} ${db} < ${tool_path}/db/tables.sql",
    user    => 'root',
    require => Exec['Create Database'],
    unless  => "echo 'use ${db}; show tables;' | mysql -u root | grep ^aufgabe$",
  }

  exec { 'Insert school':
    command => "echo \"use ${db}; insert into schule (UNr, name, mail_suffix) values (${school_id}, '${school_name}', '${school_mail_suffix}');\" | mysql -u ${user} -p${password}",
    user    => 'root',
    require => Exec['Create Tables'],
    unless  => "echo 'use ${db}; select * from schule;' | mysql -u root | grep '${school_name}'",
  }

  exec { 'Insert student':
    command => "echo \"use ${db}; insert into student (SNr, MNr, Email, Name, Vorname, Status, UNr, Passwort) values (${minister_id}, '${minister_matrikel_number}', '${minister_email}', '${minister_familyname}', '${minister_name}', 'aktiv', '${school_id}', '\"\$(${minister_password_enc})\"');\" | mysql -u ${user} -p${password}",
    user    => 'root',
    require => Exec['Create Tables'],
    unless  => "echo 'use ${db}; select * from student;' | mysql -u root | grep '${minister_familyname}'",
  }

  exec { 'Insert minister':
    command => "echo 'use ${db}; insert into minister (SNr) values (${minister_id});' | mysql -u ${user} -p${password}",
    user    => 'root',
    require => Exec['Create Tables'],
    unless  => "echo 'use ${db}; select * from minister;' | mysql -u root | grep '${minister_id}'",
  }

  exec { 'Insert direktor':
    command => "echo 'use ${db}; insert into direktor (SNr, UNr) values (${minister_id},${school_id});' | mysql -u ${user} -p${password}",
    user    => 'root',
    require => Exec['Create Tables'],
    unless  => "echo 'use ${db}; select * from direktor;' | mysql -u root | grep '${minister_id}'",
  }
}
