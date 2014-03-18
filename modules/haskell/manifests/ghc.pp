###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell::ghc ($libgmp, $libgmp_dev, $version) {
  $versionname = "ghc-${version}"
  # $hardwaremodel is either 'i386' or 'x86_64'
  $hardwaremodel = inline_template("<%= %x{uname -i | tr -d '\n'} %>")
  $path = "/home/vagrant/${versionname}"
  $archive_name = "${versionname}-${hardwaremodel}-unknown-linux.tar.bz2"
  $archive = "/home/vagrant/${versionname}-${hardwaremodel}-unknown-linux.tar.bz2"

  exec { 'ghc download':
    command => "wget http://www.haskell.org/ghc/dist/${version}/${archive_name}",
    unless  => "test `ghc --version | awk '{print \$NF}'` = ${version}",
  }

  exec { 'ghc extract':
    command => "tar -xf ${archive}",
    creates => $path,
    require => Exec['ghc download'],
    onlyif  => "test -f ${archive}",
  }

  package { $libgmp:
    ensure => latest,
  }

  package { $libgmp_dev:
    ensure  => latest,
    require => Package[$libgmp],
  }

  exec { 'ghc configure':
    command => "${path}/configure --prefix=/usr/local",
    cwd     => $path,
    require =>
      [ Exec['ghc extract'],
        Package[$libgmp_dev] ],
    onlyif  => "test -d ${path}",
  }

  exec { "install ${versionname}":
    command => 'make install',
    user    => 'root',
    cwd     => $path,
    require => Exec['ghc configure'],
    onlyif  => "test -d ${path}",
  }

  file {
    [$path, $archive]:
      ensure  => absent,
      force   => true,
      recurse => true,
      require =>
        [ Exec["install ${versionname}"],
          Exec['ghc configure'] ],
  }
}
