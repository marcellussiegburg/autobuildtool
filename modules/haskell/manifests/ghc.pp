###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell::ghc ($libgmp, $libgmp_dev, $version) {
  $versionname = "ghc-${version}"
  # $hardwaremodel is either 'i386' or 'x86_64'
  $hardwaremodel = inline_template("<%= %x{uname -i | tr -d '\n'} %>")
  $archive = "${versionname}-${hardwaremodel}-unknown-linux.tar.bz2"

  exec { 'ghc download':
    command => "wget http://www.haskell.org/ghc/dist/${version}/${archive}",
    user    => 'vagrant',
    cwd     => '/home/vagrant',
    unless  => "test `ghc --version | awk '{print \$NF}'` = ${version}",
  }

  exec { 'ghc extract':
    command => "tar -xf ${archive}",
    creates => "/home/vagrant/${versionname}",
    user    => 'vagrant',
    cwd     => '/home/vagrant',
    require => Exec['ghc download'],
    onlyif  => "test -f /home/vagrant/${archive}",
  }

  package { $libgmp:
    ensure => latest,
  }

  package { $libgmp_dev:
    ensure  => latest,
    require => Package[$libgmp],
  }

  exec { 'ghc configure':
    command => "/home/vagrant/${versionname}/configure --prefix=/usr/local",
    user    => 'vagrant',
    cwd     => "/home/vagrant/${versionname}",
    require =>
      [ Exec['ghc extract'],
        Package[$libgmp_dev] ],
    onlyif  => "test -d /home/vagrant/${versionname}",
  }

  exec { "install ${versionname}":
    command => 'sudo make install',
    cwd     => "/home/vagrant/${versionname}",
    require => Exec['ghc configure'],
    onlyif  => "test -d /home/vagrant/${versionname}",
  }

  file {
    [ "/home/vagrant/${versionname}", "/home/vagrant/${archive}" ]:
      ensure  => absent,
      force   => true,
      recurse => true,
      require =>
        [ Exec["install ${versionname}"],
          Exec['ghc configure'] ],
  }
}
