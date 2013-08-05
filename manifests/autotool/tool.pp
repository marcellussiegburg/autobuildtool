###  (c) Marcellus Siegburg, 2013, License: GPL
class autotool::tool {
  include autotool::autolib
  
  exec { 'git-clone':
    command => "git clone git://autolat.imn.htwk-leipzig.de/git/tool /home/vagrant/tool",
    user => "vagrant",
    cwd => "/home/vagrant",
    unless => "test -d /home/vagrant/tool",
    require => Class["autotool::autolib"],
  }
  
  exec { 'checkout':
    command => "git checkout -f remotes/origin/classic-via-rpc",
    cwd => "/home/vagrant/tool",
    require => Exec["git-clone"],
    onlyif => "test -d /home/vagrant/tool",
  }
  
  cabalinstall { 'interface':
    name => "autotool-interface",
    cwd => "/home/vagrant/tool/interface",
    require => Exec["checkout"],
    onlyif => "test -d /home/vagrant/tool",
  }

  file { '/home/vagrant/tool/collection/dist':
    name => "/home/vagrant/tool/collection/dist",
    ensure => directory,
    group => "vagrant",
    owner => "vagrant",
    recurse => true,
    require => Exec["checkout"],
    before => Cabalinstall["collection"],
  }
  
  cabalinstall { 'collection':
    name => "autotool-collection",
    cwd => "/home/vagrant/tool/collection",
    require => Cabalinstall["interface"],
    onlyif => "test -d /home/vagrant/tool",
  }
  
  file { 'Mysqlconnect.hs link':
    ensure => link,
    name => "/home/vagrant/tool/db/src/Mysqlconnect.hs",
    target => "/home/vagrant/tool/db/src/Mysqlconnect.hs.example",
    require => Exec["checkout"],
  }
  
  cabalinstall { 'db':
    name => "autotool-db",
    cwd => "/home/vagrant/tool/db",
    require => [ Cabalinstall["interface"],
                 Cabalinstall["collection"],
                 Cabalinstall["server-interface"],
                 File["Mysqlconnect.hs link"] ],
    onlyif => "test -d /home/vagrant/tool",
  }

  # cabalinstall { 'test':
  #   name => "autotool-test",
  #   cwd => "/home/vagrant/tool/test",
  #   require => [ Cabalinstall["collection"],
  #                Cabalinstall["interface"],
  #                Cabalinstall["db"]],
  #   onlyif => "test -d /home/vagrant/tool",
  # }

  cabalinstall { 'server-interface':
    name => "autotool-server-interface",
    cwd => "/home/vagrant/tool/server-interface",
    require => Cabalinstall["interface"],
    onlyif => "test -d /home/vagrant/tool",
  }
  
  file { 'Config.hs link':
    ensure => link,
    name => "/home/vagrant/tool/server-implementation/src/Config.hs",
    target => "/home/vagrant/tool/server-implementation/src/Config.hs.sample",
    require => Exec["checkout"],
  }

  exec { 'server-implementation':
    command => "cabal install",
    cwd => "/home/vagrant/tool/server-implementation",
    require => [ Cabalinstall["collection"],
                 Cabalinstall["server-interface"],
                 File["Config.hs link"] ],
    onlyif => "test -d /home/vagrant/tool",
    unless => "test -x /home/vagrant/.cabal/bin/autotool.cgi",
  }

  exec { 'Prepare client':
    command => ["sed 's/\\-\\- autotool-server/autotool-server-interface/' autotool-client.cabal > tmp.cabal; cat tmp.cabal > autotool-client.cabal; rm tmp.cabal"],
    cwd => "/home/vagrant/tool/client",
    require => Exec["checkout"],
    onlyif => "test -d /home/vagrant/tool",
    unless => "cabal list --installed --simple-output | grep autolat-client",
  }
  
  cabalinstall { 'client':
    name => "autolat-client",
    cwd => "/home/vagrant/tool/client",
    file => "$cwd/autotool-client.cabal",
    require => [ Exec["checkout"],
                 Cabalinstall["server-interface"],
                 Exec["Prepare client"] ],
    onlyif => "test -d /home/vagrant/tool",
  }
  
}
