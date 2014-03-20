###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell::cabal_install ($zlib_dev, $version) {
  $url = 'http://www.haskell.org/cabal/release'
  $install_name = "cabal-install-${version}"
  $path = "/home/vagrant/${install_name}"
  $archive = "${path}.tar.gz"

  exec { 'cabal-install download':
    command => "wget ${url}/${install_name}/${install_name}.tar.gz",
    creates => $archive,
    unless  => "test \"`cabal --version | head -1 | awk '{print \$NF}'`\" = ${version}",
  }

  exec { 'cabal-install extract':
    command => "tar -xf ${archive}",
    creates => $path,
    require => Exec['cabal-install download'],
    onlyif  => "test -f ${archive}",
  }

  package { $zlib_dev:
    ensure => latest,
  }

  exec { 'cabal-install bootstrap':
    command => 'bash -Ec "CURL=\'curl -L\' sh bootstrap.sh"',
    cwd     => $path,
    require =>
      [ Exec['cabal-install extract'],
        Package[$zlib_dev] ],
    onlyif  => "test -d ${path}"
  }

  file {
    'cabal-install link':
      ensure  => link,
      path    => '/usr/local/bin/cabal',
      target  => '/home/vagrant/.cabal/bin/cabal',
      require => Exec['cabal-install bootstrap'];
    $archive:
      ensure  => absent,
      force   => true,
      recurse => true,
      require => Exec['cabal-install extract'];
    $path:
      ensure  => absent,
      force   => true,
      recurse => true,
      require => Exec['cabal-install bootstrap'];
  }
}
