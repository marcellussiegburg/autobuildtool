###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell::cabal ($version) {
  $url = 'http://www.haskell.org/cabal/release'
  $cabal_name = "Cabal-${version}"
  $path = "/home/vagrant/${cabal_name}"
  $archive = "${path}.tar.gz"
  $filter = 'awk -F\'.\' \'{print $1"."$2"."$3}\''

  exec { 'cabal download':
    command => "wget ${::haskell::wget_param} ${url}/cabal-${version}/${cabal_name}.tar.gz",
    creates => $archive,
    unless  => "test \"`cabal --version | tail -1 | awk '{print \$3}' | ${filter}`\" = \"`echo ${version} | ${filter}`\"",
  }

  exec { 'cabal extract':
    command => "tar -xf ${archive}",
    creates => $path,
    require => Exec['cabal download'],
    onlyif  => "test -f ${archive}",
  }

  exec { 'cabal make':
    command => 'ghc --make Setup',
    cwd     => $path,
    require => Exec['cabal extract'],
    onlyif  => "test -d ${path}"
  }

  exec { 'cabal configure':
    command => "${path}/Setup configure",
    cwd     => $path,
    require => Exec['cabal make'],
    onlyif  => "test -d ${path}"
  }

  exec { 'cabal build':
    command => "${path}/Setup build",
    cwd     => $path,
    require => Exec['cabal configure'],
    onlyif  => "test -d ${path}"
  }

  exec { 'cabal install':
    command => "${path}/Setup install",
    user    => 'root',
    cwd     => $path,
    require => Exec['cabal build'],
    onlyif  => "test -d ${path}"
  }

  file {
    $archive:
      ensure  => absent,
      force   => true,
      recurse => true,
      require => Exec['cabal extract'];
    $path:
      ensure  => absent,
      force   => true,
      recurse => true,
      require =>
        [ Exec['cabal configure'],
          Exec['cabal make'],
          Exec['cabal build'],
          Exec['cabal install'] ];
  }
}
