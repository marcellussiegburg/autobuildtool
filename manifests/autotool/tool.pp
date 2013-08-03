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
  
  exec { 'interface':
    command => "cabal install",
    cwd => "/home/vagrant/tool/interface",
    require => Exec["checkout"],
    onlyif => "test -d /home/vagrant/tool",
    unless => "cabal list --installed --simple-output | grep autotool-interface",
  }

  file { '/home/vagrant/tool/collection/dist':
    name => "/home/vagrant/tool/collection/dist",
    ensure => directory,
    group => "vagrant",
    owner => "vagrant",
    recurse => true,
    require => Exec["checkout"],
    before => Exec["collection"],
  }
  
  exec { 'collection':
    command => "cabal install",
    cwd => "/home/vagrant/tool/collection",
    require => Exec["interface"],
    onlyif => "test -d /home/vagrant/tool",
    unless => "cabal list --installed --simple-output | grep autotool-collection",
  }
  
  file { 'Mysqlconnect.hs link':
    ensure => link,
    name => "/home/vagrant/tool/db/src/Mysqlconnect.hs",
    target => "/home/vagrant/tool/db/src/Mysqlconnect.hs.example",
    require => Exec["checkout"],
  }
  
  exec { 'db':
    command => "cabal install",
    require => [ Exec["interface"],
                 Exec["collection"],
                 Exec["server-interface"],
                 File["Mysqlconnect.hs link"] ],
    cwd => "/home/vagrant/tool/db",
    onlyif => "test -d /home/vagrant/tool",
    unless => "cabal list --installed --simple-output | grep autotool-db",
  }

  # exec { 'test':
  #   command => "cabal install",
  #   cwd => "/home/vagrant/tool/test",
  #   require => [ Exec["collection"],
  #                Exec["interface"],
  #                Exec["db"]],
  #   onlyif => "test -d /home/vagrant/tool",
  #   unless => "cabal list --installed --simple-output | grep autotool-test",
  # }

  exec { 'server-interface':
    command => "cabal install",
    cwd => "/home/vagrant/tool/server-interface",
    require => Exec["interface"],
    onlyif => "test -d /home/vagrant/tool",
    unless => "cabal list --installed --simple-output | grep autotool-server-interface",
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
    require => [ Exec["collection"],
                 Exec["server-interface"],
                 File["Config.hs link"] ],
    onlyif => "test -d /home/vagrant/tool",
    unless => "test -x /home/vagrant/.cabal/bin/autotool.cgi",
  }

  # exec { 'client':
  #   command => "cabal install",
  #   cwd => "/home/vagrant/tool/client",
  #   require => Exec["checkout"],
  #   onlyif => "test -d /home/vagrant/tool",
  #   unless => "cabal list --installed --simple-output | grep autotool-client",
  # }
  
}
