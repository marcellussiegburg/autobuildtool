###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool::tool ($build_doc = $autotool::build_doc, $url, $branch) {
  $cgi_bin = $::autotool::cgi_bin
  $html_dir = $::autotool::html_dir
  case $::architecture {
    x86_64: {
      $lib_dirs = '/usr/lib64/mysql'
    }
    default: {
      $lib_dirs = '/usr/lib/mysql'
    }
  }

  exec { 'git clone tool':
    command => "git clone ${url} /home/vagrant/tool",
    unless  => 'test -d /home/vagrant/tool',
  }

  exec { 'git fetch tool':
    command => 'git fetch',
    cwd     => '/home/vagrant/tool',
    require => Exec['git clone tool'],
    onlyif  => 'test -d /home/vagrant/tool',
  }

  exec { 'git checkout tool':
    command => "git branch -f ${branch} ${branch}; git checkout ${branch}",
    cwd     => '/home/vagrant/tool',
    require => Exec['git fetch tool'],
    onlyif  => 'test -d /home/vagrant/tool',
  }

  exec { 'git merge tool':
    command => "git merge --ff remotes/origin/${branch} || git merge --ff ${branch}",
    cwd     => '/home/vagrant/tool',
    require => Exec['git checkout tool'],
    onlyif  => 'test -d /home/vagrant/tool',
  }

  cabalinstall { 'interface':
    name      => 'autotool-interface',
    cwd       => '/home/vagrant/tool/interface',
    build_doc => $build_doc,
    require   => Exec['git merge tool'],
    onlyif    => 'test -d /home/vagrant/tool',
  }

  cabalinstall { 'collection':
    name      => 'autotool-collection',
    cwd       => '/home/vagrant/tool/collection',
    build_doc => $build_doc,
    require   => Cabalinstall['interface'],
    onlyif    => 'test -d /home/vagrant/tool',
  }

  file { 'Mysqlconnect.hs link':
    ensure  => link,
    name    => '/home/vagrant/tool/db/src/Mysqlconnect.hs',
    target  => '/home/vagrant/tool/db/src/Mysqlconnect.hs.example',
    require => Exec['git checkout tool'],
  }

  file { 'Default.hs link':
    ensure  => link,
    name    => '/home/vagrant/tool/db/src/Default.hs',
    target  => '/home/vagrant/tool/db/src/Default.hs.sample',
    require => Exec['git checkout tool'],
  }

  cabalinstall { 'db':
    name           => 'autotool-db',
    cwd            => '/home/vagrant/tool/db',
    build_doc      => $build_doc,
    extra_lib_dirs => $lib_dirs,
    require        =>
      [ Cabalinstall['interface'],
        Cabalinstall['collection'],
        Cabalinstall['server-interface'],
        File['Mysqlconnect.hs link'],
        File['Default.hs link'] ],
    onlyif         => 'test -d /home/vagrant/tool',
  }

  # cabalinstall { 'test':
  #   name      => 'autotool-test',
  #   cwd       => '/home/vagrant/tool/test',
  #   build_doc => $build_doc,
  #   require   =>
  #     [ Cabalinstall['collection'],
  #       Cabalinstall['interface'],
  #       Cabalinstall['db']],
  #   onlyif    => 'test -d /home/vagrant/tool',
  # }

  cabalinstall { 'server-interface':
    name      => 'autotool-server-interface',
    cwd       => '/home/vagrant/tool/server-interface',
    build_doc => $build_doc,
    require   => Cabalinstall['interface'],
    onlyif    => 'test -d /home/vagrant/tool',
  }

  file { 'Config.hs link':
    ensure  => link,
    name    => '/home/vagrant/tool/server-implementation/src/Config.hs',
    target  => '/home/vagrant/tool/server-implementation/src/Config.hs.sample',
    require => Exec['git checkout tool'],
  }

  cabalinstall { 'server-implementation':
    name      => 'autotool-server-implementation',
    cwd       => '/home/vagrant/tool/server-implementation',
    build_doc => $build_doc,
    require   =>
      [ Cabalinstall['collection'],
        Cabalinstall['server-interface'],
        File['Config.hs link'] ],
    onlyif    => 'test -d /home/vagrant/tool',
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
  #   cwd     => '/home/vagrant/tool/client',
  #   require => Exec['git checkout tool'],
  #   onlyif  => 'test -d /home/vagrant/tool',
  # }

  # cabalinstall { 'client':
  #   name      => 'autolat-client',
  #   cwd       => '/home/vagrant/tool/client',
  #   creates   => '/home/vagrant/.cabal/bin/autotool-happs',
  #   build_doc => $build_doc,
  #   file      => "$cwd/autotool-client.cabal",
  #   require   =>
  #     [ Exec['git checkout tool'],
  #       Cabalinstall['server-interface'],
  #       Exec['Prepare client'] ],
  #   onlyif    => 'test -d /home/vagrant/tool',
  # }
}
