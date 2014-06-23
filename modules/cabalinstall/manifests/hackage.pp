###  (c) Marcellus Siegburg, 2014, License: GPL
define cabalinstall::hackage ($build_doc = true, $keep = false,
$extra_lib_dirs = '', $maxruns = $::haskell::maxruns, $onlyif = undef,
$unless = undef, $version = undef) {
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
    $unl = "ghc-pkg list ${package} | grep ${package}"
  } else {
    $unl = $unless
  }
  $multirun = '/vagrant/modules/cabalinstall/files/multi-run.sh'
  $outofmemory = '-e "ExitFailure 9" -e "ExitFailure 11"'
  $cabal_install = "cabal install ${doc} ${libs} ${package}"
  $other_versions = "ghc-pkg list ${name} | grep ${name} | grep -v ${package}"
  $remove = "for i in \$(${other_versions}); do ghc-pkg unregister \$i; done"
  exec { "cabal install ${title}":
    command => "bash '${multirun}' '${outofmemory}' '${cabal_install}' ${maxruns} 0",
    onlyif  => $onlyif,
    unless  => $unless,
  }
  if ($keep == false) {
    exec { "ghc-pkg unregister ${title}":
      command => "bash -Ec '${remove}'",
      onlyif  => $onlyif,
      unless  => $unless,
      before  => Exec["cabal install ${title}"],
      returns => [0, 1],
    }
  }
}
