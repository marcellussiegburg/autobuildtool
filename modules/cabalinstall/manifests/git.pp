###  (c) Marcellus Siegburg, 2014, License: GPL
define cabalinstall::git ($branch = 'master', $unless = undef, $version = undef,
$url = undef) {
  $package = $version ? {
    undef    => $name,
    default  => "${name}-${version}",
  }
  $path = $::haskell::git_path
  exec { "git clone ${title}":
    command => "git clone ${url} ${path}/${package}",
    creates => "${path}/${package}",
  }

  exec { "git fetch ${package}":
    command => 'git fetch',
    cwd     => "${path}/${package}",
    onlyif  => "test -d ${path}/${package}",
    unless  => $unless,
    require => Exec["git clone ${title}"],
  }

  exec { "checkout ${package}":
    command => "git branch -f ${branch} ${branch}; git checkout ${branch}",
    cwd     => "${path}/${package}",
    onlyif  => "test -d ${path}/${package}",
    unless  => $unless,
    require => Exec["git fetch ${package}"],
  }
}
