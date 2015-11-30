###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool::tool ($build_doc = $::autotool::build_doc) {
  $path = $::autotool::autotool_path
  $cgi_bin = $::autotool::cgi_bin
  $html_dir = $::autotool::html_dir

  Cabalinstall {
    constraints => $::autotool::dependencies::dependency_constraints,
    build_doc   => $build_doc,
    cwd         => $::autotool::install_path,
  }

  cabalinstall { 'interface':
    name   => 'autotool-interface',
    path   => "${path}/interface",
    onlyif => "test -d ${path}/interface",
  }

  cabalinstall { 'collection':
    name    => 'autotool-collection',
    path    => "${path}/collection",
    require => Cabalinstall['interface'],
    onlyif  => "test -d ${path}/collection",
  }

  file { 'Mysqlconnect.hs link':
    ensure => link,
    name   => "${path}/db/src/Mysqlconnect.hs",
    target => "${path}/db/src/Mysqlconnect.hs.example",
  }

  file { 'Default.hs link':
    ensure => link,
    name   => "${path}/db/src/Default.hs",
    target => "${path}/db/src/Default.hs.sample",
  }

  cabalinstall { 'db':
    name    => 'autotool-db',
    path    => "${path}/db",
    require =>
      [ Cabalinstall['interface'],
        Cabalinstall['collection'],
        Cabalinstall['server-interface'],
        File['Mysqlconnect.hs link'],
        File['Default.hs link'] ],
    onlyif  => "test -d ${path}/db",
  }

  cabalinstall { 'yesod':
    name    => 'autotool-yesod',
    path    => "${path}/yesod",
    require =>
      [ Cabalinstall['interface'],
        Cabalinstall['collection'],
        Cabalinstall['server-interface'],
        Cabalinstall['db'] ],
    onlyif  => "test -d ${path}/yesod",
    unless  => "test -f ${::autotool::install_path}/.cabal-sandbox/bin/autotool-yesod.cgi && test -z $(find ${path}/yesod -type f -path ${::autotool::install_path}/.cabal-sandbox -prune -newer ${::autotool::install_path}/.cabal-sandbox/bin/autotool-yesod.cgi)",
  }

  # cabalinstall { 'test':
  #   name      => 'autotool-test',
  #   path      => "${path}/test",
  #   build_doc => $build_doc,
  #   require   =>
  #     [ Cabalinstall['collection'],
  #       Cabalinstall['interface'],
  #       Cabalinstall['db']],
  #   onlyif    => "test -d ${path}/test",
  # }

  cabalinstall { 'server-interface':
    name    => 'autotool-server-interface',
    path    => "${path}/server-interface",
    require => Cabalinstall['interface'],
    onlyif  => "test -d ${path}/server-interface",
  }

  file { 'Config.hs link':
    ensure  => link,
    name    => "${path}/server-implementation/src/Config.hs",
    target  => "${path}/server-implementation/src/Config.hs.sample",
  }

  cabalinstall { 'server-implementation':
    name    => 'autotool-server-implementation',
    path    => "${path}/server-implementation",
    require =>
      [ Cabalinstall['collection'],
        Cabalinstall['server-interface'],
        File['Config.hs link'] ],
    onlyif  => "test -d ${path}/server-implementation",
    unless  => "test -f ${::autotool::install_path}/.cabal-sandbox/bin/autotool.cgi && test -z $(find ${path}/server-implementation -type f -newer ${::autotool::install_path}/.cabal-sandbox/bin/autotool.cgi)",
  }

  file { "${cgi_bin}/autotool-yesod.cgi":
    ensure  => file,
    owner   => $::apache::apache_user,
    group   => $::apache::apache_user,
    require => Cabalinstall['yesod'],
    source  => "${::autotool::install_path}/.cabal-sandbox/bin/autotool-yesod.cgi",
  }

  file { "${cgi_bin}/autotool.cgi":
    ensure  => file,
    owner   => $::apache::apache_user,
    group   => $::apache::apache_user,
    require => Cabalinstall['server-implementation'],
    source  => "${::autotool::install_path}/.cabal-sandbox/bin/autotool.cgi",
  }

  file {
    "${::autotool::install_path}/config/mysql.yml":
      ensure  => link,
      require => Cabalinstall['yesod'],
      target  => "${path}/yesod/config/mysql.sample.yml";
    "${cgi_bin}/Super.cgi":
      ensure  => file,
      require => Cabalinstall['db'],
      owner   => $::apache::apache_user,
      group   => $::apache::apache_user,
      source  => "${::autotool::install_path}/.cabal-sandbox/bin/autotool-Super";
    "${cgi_bin}/Trial.cgi":
      ensure  => file,
      require => Cabalinstall['db'],
      owner   => $::apache::apache_user,
      group   => $::apache::apache_user,
      source  => "${::autotool::install_path}/.cabal-sandbox/bin/autotool-Trial";
    [$html_dir, $cgi_bin]:
      ensure  => directory,
      require => Cabalinstall['db'],
      owner   => $::apache::apache_user,
      group   => $::apache::apache_user;
  }

  # exec { 'Prepare client':
  #   command => ['sed "s/\\-\\- autotool-server/autotool-server-interface/" autotool-client.cabal > tmp.cabal; cat tmp.cabal > autotool-client.cabal; rm tmp.cabal'],
  #   path    => "${path}/client",
  #   onlyif  => "test -d ${path}",
  # }

  # cabalinstall { 'client':
  #   name      => 'autolat-client',
  #   path      => "${path}/client",
  #   creates   => "${::autotool::install_path}/.cabal-sandbox/bin/autotool-happs",
  #   file      => "$cwd/autotool-client.cabal",
  #   require   =>
  #     [ Cabalinstall['server-interface'],
  #       Exec['Prepare client'] ],
  #   onlyif    => "test -d ${path}/client",
  # }
}
