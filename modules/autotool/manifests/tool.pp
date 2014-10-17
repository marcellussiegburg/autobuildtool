###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool::tool ($build_doc = $::autotool::build_doc) {
  $path = $::autotool::autotool_path
  $cgi_bin = $::autotool::cgi_bin
  $html_dir = $::autotool::html_dir

  Cabalinstall {
    constraints => $::autotool::dependencies::dependency_constraints,
    build_doc => $build_doc,
  }

  cabalinstall { 'interface':
    name      => 'autotool-interface',
    cwd       => "${path}/interface",
    onlyif    => "test -d ${path}/interface",
  }

  cabalinstall { 'collection':
    name      => 'autotool-collection',
    cwd       => "${path}/collection",
    require   => Cabalinstall['interface'],
    onlyif    => "test -d ${path}/collection",
  }

  file { 'Mysqlconnect.hs link':
    ensure  => link,
    name    => "${path}/db/src/Mysqlconnect.hs",
    target  => "${path}/db/src/Mysqlconnect.hs.example",
  }

  file { 'Default.hs link':
    ensure  => link,
    name    => "${path}/db/src/Default.hs",
    target  => "${path}/db/src/Default.hs.sample",
  }

  cabalinstall { 'db':
    name           => 'autotool-db',
    cwd            => "${path}/db",
    require        =>
      [ Cabalinstall['interface'],
        Cabalinstall['collection'],
        Cabalinstall['server-interface'],
        File['Mysqlconnect.hs link'],
        File['Default.hs link'] ],
    onlyif         => "test -d ${path}/db",
  }

  # cabalinstall { 'test':
  #   name      => 'autotool-test',
  #   cwd       => "${path}/test",
  #   build_doc => $build_doc,
  #   require   =>
  #     [ Cabalinstall['collection'],
  #       Cabalinstall['interface'],
  #       Cabalinstall['db']],
  #   onlyif    => "test -d ${path}/test",
  # }

  cabalinstall { 'server-interface':
    name      => 'autotool-server-interface',
    cwd       => "${path}/server-interface",
    require   => Cabalinstall['interface'],
    onlyif    => "test -d ${path}/server-interface",
  }

  file { 'Config.hs link':
    ensure  => link,
    name    => "${path}/server-implementation/src/Config.hs",
    target  => "${path}/server-implementation/src/Config.hs.sample",
  }

  cabalinstall { 'server-implementation':
    name      => 'autotool-server-implementation',
    cwd       => "${path}/server-implementation",
    require   =>
      [ Cabalinstall['collection'],
        Cabalinstall['server-interface'],
        File['Config.hs link'] ],
    onlyif    => "test -d ${path}/server-implementation",
  }

  file { "${cgi_bin}/autotool.cgi":
    ensure  => file,
    owner   => 'apache',
    group   => 'apache',
    require => Cabalinstall['server-implementation'],
    source  => '/home/vagrant/.cabal/bin/autotool.cgi',
  }

  file {
    "${cgi_bin}/Super.cgi":
      ensure  => file,
      require => Cabalinstall['db'],
      owner   => 'apache',
      group   => 'apache',
      source  => '/home/vagrant/.cabal/bin/autotool-Super';
    "${cgi_bin}/Trial.cgi":
      ensure  => file,
      require => Cabalinstall['db'],
      owner   => 'apache',
      group   => 'apache',
      source  => '/home/vagrant/.cabal/bin/autotool-Trial';
    [$html_dir, $cgi_bin]:
      ensure  => directory,
      require => Cabalinstall['db'],
      owner   => 'apache',
      group   => 'apache';
  }

  # exec { 'Prepare client':
  #   command => ['sed "s/\\-\\- autotool-server/autotool-server-interface/" autotool-client.cabal > tmp.cabal; cat tmp.cabal > autotool-client.cabal; rm tmp.cabal'],
  #   cwd     => "${path}/client",
  #   onlyif  => "test -d ${path}",
  # }

  # cabalinstall { 'client':
  #   name      => 'autolat-client',
  #   cwd       => "${path}/client",
  #   creates   => '/home/vagrant/.cabal/bin/autotool-happs',
  #   file      => "$cwd/autotool-client.cabal",
  #   require   =>
  #     [ Cabalinstall['server-interface'],
  #       Exec['Prepare client'] ],
  #   onlyif    => "test -d ${path}/client",
  # }
}
