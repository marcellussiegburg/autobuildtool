###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell::ghc {
  case $operatingsystem {
    ubuntu: {
      $libgmp = 'libgmp3c2'
      $libgmp_dev = 'libgmp3-dev'
    }
    CentOS: {
      $libgmp = 'gmp'
      $libgmp_dev = 'gmp-devel'
    }
    default: {
      fail('Unrecognized operating system for libgmp')
    }
  }
  $version = "7.6.1"
  $versionname = "ghc-${version}"
  $hardwaremodel = inline_template("<%= %x{uname -i | tr -d '\n'} %>") # (either i386 or x86_64)
  $archive = "${versionname}-${hardwaremodel}-unknown-linux.tar.bz2"
  
  exec { 'ghc download':
    command => "wget http://www.haskell.org/ghc/dist/${version}/${archive}",
    user => "vagrant",
    cwd => "/home/vagrant",
    unless => "test `ghc --version | awk '{print \$NF}'` = ${version}",
  }
  
  exec { 'ghc extract':
    command => "tar -xf ${archive}",
    creates => "/home/vagrant/${versionname}",
    user => "vagrant",
    cwd => "/home/vagrant",
    require => Exec["ghc download"],
    onlyif => "test -f /home/vagrant/${archive}",
  }

  package { 'libgmp3':
    name => $libgmp,
    ensure => latest,
  }
  
  package { 'libgmp3-dev':
    name => $libgmp_dev,
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
  
  exec { "install ${versionname}":
    command => "sudo make install",
    cwd => "/home/vagrant/${versionname}",
    require => Exec["ghc configure"],
    onlyif => "test -d /home/vagrant/${versionname}",
  }

  file {
    [ "/home/vagrant/${versionname}", "/home/vagrant/${archive}" ]:
      ensure  => absent,
      force   => true,
      recurse => true,
      require =>
        [ Exec["install ${versionname}"],
          Exec["ghc configure"] ],
  }
} 
