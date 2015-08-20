###  (c) Marcellus Siegburg, 2014, License: GPL
define cabalinstall::hackage ($build_doc = true, $bindir = undef,
$keep = false, $extra_lib_dirs = undef, $maxruns = $::haskell::maxruns,
$onlyif = undef, $sandbox = false, $keep_sb = false, $unless = undef,
$version = undef, $cwd = '/home/vagrant') {
  $package = $version ? {
    undef    => $name,
    default  => "${name}-${version}",
  }
  if ($build_doc == true) {
    $doc = "--enable-documentation $::haskell::doc_params"
  } else {
    $doc = '--disable-documentation'
  }
  if ($extra_lib_dirs == undef) {
    $libs = ''
  } else {
    $libs = "--extra-lib-dirs=${extra_lib_dirs}"
  }
  if ($unless == undef) {
    $unl = "ghc-pkg list ${package} | grep ${package}"
  } else {
    $unl = $unless
  }
  if ($bindir == undef) {
    $bind = ''
  } else {
    $bind = "--bindir=${bindir}"
  }
  $multirun = '/vagrant/modules/cabalinstall/files/multi-run.sh'
  $outofmemory = '-e "ExitFailure 9" -e "ExitFailure 11"'
  $cabal_install = "cabal install ${bind} ${doc} ${libs} ${package}"
  $other_versions = "ghc-pkg list ${name} | grep ${name} | grep -v ${package}"
  $remove = "for i in \$(${other_versions}); do ghc-pkg unregister \$i; done"
  $command = "bash '${multirun}' '${outofmemory}' '${cabal_install}' ${maxruns} 0"
  if ($sandbox == true) {
    $user = 'root'
    if ($keep_sb == true) {
      $sb = $cwd
    } else {
      $sb = "/tmp/sandbox-${title}"
      exec { "remove sandbox ${sb} for ${title}":
        command => "rm -rf ${sb}",
        user    => $user,
        require => Exec["cabal install ${title}"],
        onlyif  => $onlyif,
        unless  => $unl,
      }
    }
    exec { "initialize sandbox ${sb} for ${title}":
      command => "rm -rf ${sb}; mkdir -p ${sb}; cd ${sb}; cabal sandbox init",
      user    => $user,
      before  => Exec["cabal install ${title}"],
      onlyif  => $onlyif,
      unless  => $unl,
    }
  } else {
    $sb = $cwd
    $user = 'vagrant'
  }
  exec { "cabal install ${title}":
    command => $command,
    cwd     => $sb,
    user    => $user,
    onlyif  => $onlyif,
    unless  => $unl,
  }
  if ($keep == false and $sandbox == false) {
    exec { "ghc-pkg unregister ${title}":
      command => "bash -Ec '${remove}'",
      cwd     => $sb,
      onlyif  => $onlyif,
      unless  => $unl,
      before  => Exec["cabal install ${title}"],
      returns => [0, 1],
    }
  }
}
