###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell::ghc ($libgmp, $libgmp_dev, $version) {
  $versionname = "ghc-${version}"
  # $hardwaremodel is either 'i386' or 'x86_64'
  $hardwaremodel = inline_template("<%= %x{uname -i | tr -d '\n'} %>")
  $osversion = $version ? {
    /^7.8.\d$/ => $osfamily ? {
      'redhat' => '-centos65',
      'debian' => '-deb7',
    },
    /^7.10.\d$/ => $osfamily ? {
      'redhat' => '-centos66',
      'debian' => '-deb7',
    },
    default    => '',
  }
  $path = "/home/vagrant/${versionname}"
  $archive_name = "${versionname}-${hardwaremodel}-unknown-linux${osversion}.tar.bz2"
  $archive = "/home/vagrant/${archive_name}"

  exec { 'ghc download':
    command => "wget ${::haskell::wget_param} http://www.haskell.org/ghc/dist/${version}/${archive_name}",
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
