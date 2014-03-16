###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell::cabal ($zlib_dev, $version, $install_version) {
  include git
  include haskell::ghc

  $url = 'http://www.haskell.org/cabal/release'
  $cabal_name = "Cabal-${version}"
  $cabal_path = "/home/vagrant/${cabal_name}"
  $install_name = "cabal-install-${install_version}"
  $install_path = "/home/vagrant/${install_name}"

  exec { 'cabal download':
    command => "wget ${url}/cabal-${version}/${cabal_name}.tar.gz",
    creates => "${cabal_path}.tar.gz",
    user    => 'vagrant',
    cwd     => '/home/vagrant',
    require =>
      [ Class['haskell::ghc'],
        Class['git'] ],
    unless  => "test \"`cabal --version | tail -1 | awk '{print \$3}'`\" = ${version}",
  }
  
  exec { 'cabal-install download':
    command => "wget ${url}/${install_name}/${install_name}.tar.gz",
    creates => "${install_path}.tar.gz",
    user    => 'vagrant',
    cwd     => '/home/vagrant',
    require =>
      [ Class['haskell::ghc'],
        Class['git'] ],
    unless  => "test \"`cabal --version | head -1 | awk '{print \$NF}'`\" = ${version}",
  }

  exec { 'cabal extract':
    command => "tar -xf ${cabal_name}.tar.gz",
    creates => $cabal_path,
    user    => 'vagrant',
    cwd     => '/home/vagrant',
    require => Exec['cabal download'],
    onlyif  => "test -f ${cabal_path}.tar.gz",
  }
  
  exec { 'cabal-install extract':
    command => "tar -xf ${install_name}.tar.gz",
    creates => $install_path,
    user    => 'vagrant',
    cwd     => '/home/vagrant',
    require => Exec['cabal-install download'],
    onlyif  => "test -f ${install_path}.tar.gz",
  }

  exec { 'cabal make':
    command => 'ghc --make Setup',
    user    => 'vagrant',
    cwd     => $cabal_path,
    require => Exec['cabal extract'],
    onlyif  => "test -d ${cabal_path}"
  }

  exec { 'cabal configure':
    command => "${cabal_path}/Setup configure",
    user    => 'vagrant',
    cwd     => $cabal_path,
    require => Exec['cabal make'],
    onlyif  => "test -d ${cabal_path}"
  }

  exec { 'cabal build':
    command => "${cabal_path}/Setup build",
    user    => 'vagrant',
    cwd     => $cabal_path,
    require => Exec['cabal configure'],
    onlyif  => "test -d ${cabal_path}"
  }

  exec { 'cabal install':
    command => "${cabal_path}/Setup install",
    user    => 'root',
    cwd     => $cabal_path,
    require => Exec['cabal build'],
    onlyif  => "test -d ${cabal_path}"
  }

  package { $zlib_dev:
    ensure => latest,
    name   => $zlib_dev,
  }

  exec { 'cabal-install bootstrap':
    command => "bash -Ec \"CURL='curl -L' sh bootstrap.sh\"",
    user    => 'vagrant',
    cwd     => $install_path,
    require =>
      [ Exec['cabal-install extract'],
        Package[$zlib_dev] ],
    onlyif  => "test -d ${install_path}"
  }

  file {
    'cabal-install link':
      ensure  => link,
      path    => '/usr/local/bin/cabal',
      target  => '/home/vagrant/.cabal/bin/cabal',
      require => Exec['cabal-install bootstrap'];
    $cabal_path:
      ensure  => absent,
      force   => true,
      recurse => true,
      require => Exec['cabal extract'];
    $install_path:
      ensure  => absent,
      force   => true,
      recurse => true,
      require => Exec['cabal-install bootstrap'];
  }
}
