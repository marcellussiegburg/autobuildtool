###  (c) Marcellus Siegburg, 2014, License: GPL
define cabalinstall::hackage ($build_doc = true, $bindir = undef,
$keep = false, $extra_lib_dirs = undef, $maxruns = $::haskell::maxruns,
$onlyif = undef, $sandbox = false, $unless = undef, $version = undef) {
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
  if ($bindir == undef) {
    $bind = ''
  } else {
    $bind = "--bindir=${bindir}"
  }
  $sb = '/tmp/sandbox-klasdfhklsdafhk'
  $create_sb = "sudo rm -rf ${sb}; mkdir ${sb}; cd ${sb}; cabal sandbox init"
  $remove_sb = "sudo rm -rf ${sb}"
  $multirun = '/vagrant/modules/cabalinstall/files/multi-run.sh'
  $outofmemory = '-e "ExitFailure 9" -e "ExitFailure 11"'
  $cabal_install = "cabal install ${bind} ${doc} ${libs} ${package}"
  $other_versions = "ghc-pkg list ${name} | grep ${name} | grep -v ${package}"
  $remove = "for i in \$(${other_versions}); do ghc-pkg unregister \$i; done"
  $cmd = "bash '${multirun}' '${outofmemory}' '${cabal_install}' ${maxruns} 0"
  if ($sandbox == true) {
    $command = "${create_sb}; ${cmd}; ${remove_sb}"
    $user = 'root'
  } else {
    $command = $cmd
    $user = 'vagrant'
  }
  exec { "cabal install ${title}":
    command => $command,
    user    => $user,
    onlyif  => $onlyif,
    unless  => $unl,
  }
  if ($keep == false and $sandbox == false) {
    exec { "ghc-pkg unregister ${title}":
      command => "bash -Ec '${remove}'",
      onlyif  => $onlyif,
      unless  => $unl,
      before  => Exec["cabal install ${title}"],
      returns => [0, 1],
    }
  }
}
