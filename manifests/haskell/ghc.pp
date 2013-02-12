###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell::ghc {
  $version = "7.6.1"
  $versionname = "ghc-${version}"
#  $architecture is a fact (i386 or x86_64)
  
  exec { 'ghc download':
    command => "wget http://www.haskell.org/ghc/dist/${version}/${versionname}-${architecture}-unknown-linux.tar.bz2",
    user => "vagrant",
    cwd => "/home/vagrant",
    unless => "test `ghc --version | awk '{print \$NF}'` = ${version}",
  }
  
  exec { 'ghc extract':
    command => "tar -xf ${versionname}-${architecture}-unknown-linux.tar.bz2",
    user => "vagrant",
    cwd => "/home/vagrant",
    require => Exec["ghc download"],
    onlyif => "test -f /home/vagrant/${versionname}-${architecture}-unknown-linux.tar.bz2",
  }

  package { 'libgmp3':
    name => "libgmp3c2",
    ensure => latest,
  }
  
  package { 'libgmp3-dev':
    name => "libgmp3-dev",
    ensure => latest,
    require => Package["libgmp3"],
  }

  exec { 'ghc configure':
    command => "/home/vagrant/${versionname}/configure --prefix=/usr/local",
    user => "vagrant",
    cwd => "/home/vagrant/${versionname}",
    require => [ Exec["ghc extract"],
                 Package["libgmp3-dev"] ],
    onlyif => "test -d /home/vagrant/${versionname}",
  }
  
  exec { 'ghc install':
    command => "sudo make install",
    cwd => "/home/vagrant/${versionname}",
    require => Exec["ghc configure"],
    onlyif => "test -d /home/vagrant/${versionname}",
  }
  
  exec { "remove /home/vagrant/${versionname}":
    command => "rm -rf /home/vagrant/${versionname}*",
    cwd => "/home/vagrant/${versionname}",
    require => Exec["ghc install"],
    onlyif => "test -d /home/vagrant/${versionname}",
  }
} 
