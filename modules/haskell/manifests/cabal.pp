###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell::cabal {
  include git
  include haskell::ghc

  case $operatingsystem {
    ubuntu: { $zlib_dev = 'zlibc' }
    CentOS: { $zlib_dev = 'zlib-devel' }
    default: { fail('Unrecognized operating system for zlib') }
  }
  $version = '1.16'
  $version_branch = "cabal-${version}"
  $awk = 'BEGIN {FS = "."}{ print $1"."$2 }'
  
  exec { 'cabal download':
    command => "git clone git://github.com/haskell/cabal.git",
    creates => "/home/vagrant/cabal",
    user => "vagrant",
    cwd => "/home/vagrant",
    require => [ Class["haskell::ghc"],
                 Class["git"] ],
    onlyif => "test ! -d /home/vagrant/cabal",
    unless => [ "test \"`cabal --version | tail -1 | awk '{print \$3}' | awk '${awk}'`\" = ${version}",
    "test \"`cabal --version | head -1 | awk '{print \$NF}' | awk '${awk}'`\" = ${version}"],
  }
  
  exec { 'cabal git checkout':
    command => "git checkout remotes/origin/${version_branch}",
    user => "vagrant",
    cwd => "/home/vagrant/cabal",
    require => Exec["cabal download"],
    onlyif => "test -d /home/vagrant/cabal",
  }
  
  exec { 'cabal make':
    command => "ghc --make Setup",
    user => "vagrant",
    cwd => "/home/vagrant/cabal/Cabal",
    require => Exec["cabal git checkout"],
    onlyif => "test -d /home/vagrant/cabal"
  }
  
  exec { 'cabal configure':
    command => "/home/vagrant/cabal/Cabal/Setup configure",
    user => "vagrant",
    cwd => "/home/vagrant/cabal/Cabal",
    require => Exec["cabal make"],
    onlyif => "test -d /home/vagrant/cabal",
  }
  
  exec { 'cabal build':
    command => "/home/vagrant/cabal/Cabal/Setup build",
    user => "vagrant",
    cwd => "/home/vagrant/cabal/Cabal",
    require => Exec["cabal configure"],
    onlyif => "test -d /home/vagrant/cabal",
  }
  
  exec { 'cabal install':
    command => "sudo /home/vagrant/cabal/Cabal/Setup install",
    cwd => "/home/vagrant/cabal/Cabal",
    require => Exec["cabal build"],
    onlyif => "test -d /home/vagrant/cabal",
  }

  package { 'zlib-dev':
    name => $zlib_dev,
    ensure => latest,
  }

  exec { 'cabal-install bootstrap':
    command => "bash -Ec \"CURL='curl -L' sh /home/vagrant/cabal/cabal-install/bootstrap.sh\"",
    cwd => "/home/vagrant/cabal/cabal-install",
    user => "vagrant",
    require =>
      [ Exec['cabal git checkout'],
        Package['zlib-dev'] ],
    onlyif => "test -d /home/vagrant/cabal",
  }

  file {
    'cabal-install link':
      path => '/usr/local/bin/cabal',
      target => '/home/vagrant/.cabal/bin/cabal',
      ensure => link,
      require => Exec['cabal-install bootstrap'];
    '/home/vagrant/cabal': 
      ensure  => absent,
      force   => true,
      recurse => true,
      require =>
       [ Exec['cabal-install bootstrap'],
         Exec['cabal git checkout'] ];
  }
}
