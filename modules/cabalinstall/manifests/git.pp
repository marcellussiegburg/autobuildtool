###  (c) Marcellus Siegburg, 2014, License: GPL
define cabalinstall::git ($build_doc = true, $keep = false,
$extra_lib_dirs = undef, $maxruns = $::haskell::maxruns, $branch = 'master',
$unless = undef, $version = undef, $url = undef) {
  $package = $version ? {
    undef    => $name,
    default  => "${name}-${version}",
  }
  if ($build_doc == true) {
    $doc = '--enable-documentation --haddock-hyperlink-source'
  } else {
    $doc = '--disable-documentation'
  }
  if ($extra_lib_dirs == undef) {
    $libs = ''
  } else {
    $libs = "--extra-lib-dirs=${extra_lib_dirs}"
  }
  if ($unless == undef) {
    $unl = "ghc-pkg list ${package} | grep \" \"${package}"
  } else {
    $unl = $unless
  }
  $multirun = '/vagrant/modules/cabalinstall/files/multi-run.sh'
  $outofmemory = '-e "ExitFailure 9" -e "ExitFailure 11"'
  $cabal_install = "if ! $unl >/dev/null 2>/dev/null; then cabal install ${doc} ${libs}; fi"
  $other_versions = "ghc-pkg list ${name} | grep ${name} | grep -v ${package}"
  $remove = "for i in \$(${other_versions}); do ghc-pkg unregister \$i; done"
  exec { "git clone ${title}":
    command => "git clone ${url} /home/vagrant/${package}",
    creates => "/home/vagrant/${package}",
  }

  exec { "git fetch ${package}":
    command => 'git fetch',
    cwd     => "/home/vagrant/${package}",
    onlyif  => "test -d /home/vagrant/${package}",
    unless  => $unless,
    require => Exec["git clone ${title}"],
  }

  exec { "checkout ${package}":
    command => "git branch -f ${branch} ${branch}; git checkout ${branch}",
    cwd     => "/home/vagrant/${package}",
    onlyif  => "test -d /home/vagrant/${package}",
    unless  => $unless,
    require => Exec["git fetch ${package}"],
  }
  
  exec { "cabal install ${package}":
    command => "bash '${multirun}' '${outofmemory}' '${cabal_install}' ${maxruns} 0",
    cwd     => "/home/vagrant/${package}",
    onlyif  => "test -d /home/vagrant/${package}",
    unless  => $unless,
    require => Exec["checkout ${package}"],
  }
  if ($keep == false) {
    exec { "ghc-pkg unregister ${package}":
      command => "bash -Ec '${remove}'",
      onlyif  => "test -d /home/vagrant/${package}",
      unless  => $unless,
      before  => Exec["cabal install ${package}"],
      returns => [0, 1],
    }
  }
}
