###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell::cabal ($zlib_dev, $version, $install_version) {
  include git
  include haskell::ghc

  $url = 'http://www.haskell.org/cabal/release'
  $cabal_name = "Cabal-${version}"
  $cabal_path = "/home/vagrant/${cabal_name}"
  $install_name = "cabal-install-${install_version}"
  $install_path = "/home/vagrant/${install_name}"
  $filter = 'awk -F\'.\' \'{print $1"."$2"."$3}\''

  exec { 'cabal download':
    command => "wget ${url}/cabal-${version}/${cabal_name}.tar.gz",
    creates => "${cabal_path}.tar.gz",
    unless  => "test \"`cabal --version | tail -1 | awk '{print \$3}' | ${filter}`\" = \"`echo ${version} | ${filter}`\"",
  }

  exec { 'cabal extract':
    command => "tar -xf ${cabal_name}.tar.gz",
    creates => $cabal_path,
    require => Exec['cabal download'],
    onlyif  => "test -f ${cabal_path}.tar.gz",
  }

  exec { 'cabal make':
    command => 'ghc --make Setup',
    cwd     => $cabal_path,
    require => Exec['cabal extract'],
    onlyif  => "test -d ${cabal_path}"
  }

  exec { 'cabal configure':
    command => "${cabal_path}/Setup configure",
    cwd     => $cabal_path,
    require => Exec['cabal make'],
    onlyif  => "test -d ${cabal_path}"
  }

  exec { 'cabal build':
    command => "${cabal_path}/Setup build",
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

  exec { 'cabal-install download':
    command => "wget ${url}/${install_name}/${install_name}.tar.gz",
    creates => "${install_path}.tar.gz",
    unless  => "test \"`cabal --version | head -1 | awk '{print \$NF}'`\" = ${install_version}",
  }

  exec { 'cabal-install extract':
    command => "tar -xf ${install_name}.tar.gz",
    creates => $install_path,
    require => Exec['cabal-install download'],
    onlyif  => "test -f ${install_path}.tar.gz",
  }

  package { $zlib_dev:
    ensure => latest,
  }

  exec { 'cabal-install bootstrap':
    command => "bash -Ec \"CURL='curl -L' sh bootstrap.sh\"",
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
    [$cabal_path, "${cabal_path}.tar.gz"]:
      ensure  => absent,
      force   => true,
      recurse => true,
      require =>
        [ Exec['cabal configure'],
          Exec['cabal make'],
          Exec['cabal build'],
          Exec['cabal install'] ];
    [$install_path, "${install_path}.tar.gz"]:
      ensure  => absent,
      force   => true,
      recurse => true,
      require => Exec['cabal-install bootstrap'];
  }
}
