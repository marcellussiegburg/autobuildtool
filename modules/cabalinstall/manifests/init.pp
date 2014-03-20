###  (c) Marcellus Siegburg, 2013, License: GPL
define cabalinstall (
  $cwd,
  $onlyif = undef,
  $file = "${cwd}/${name}.cabal",
  $unless = undef,
  $build_doc = true,
  $maxruns = $::haskell::maxruns,
  $extra_lib_dirs = undef,
  $creates = '') {
  ### If $unless is undefined, assume that the package is installed in the following way:
    ## Extract the Version number of the installed package found in ghc-pkg
    ## Compare it to the number in the .cabal file
  $basicfilter = "ghc-pkg list | grep -n '^[ ]*${name}-[[:digit:]]'"
  $filter = "${basicfilter} | head -1"
  $dashes = "${filter} | grep -o '-' | wc -l"
  $split = "\$((1 + \$(${dashes})))"
  $version = "${filter} | cut -d'-' -f${split}"

  if ($unless == undef) {
    $unl = "bash -Ec \"grep '^Version' ${file} | grep ' '\$(${version})'\$'\""
  } else {
    $unl = $unless
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
  ### If the Version number has changed
  ## Install the .cabal file
  $multirun = '/vagrant/modules/cabalinstall/files/multi-run.sh'
  $outofmemory = '-e "ExitFailure 9" -e "ExitFailure 11"'
  $cabal_install = "cabal install ${doc} ${libs}"

  exec { "cabal install ${title} (${name})":
    command => "bash '${multirun}' '${outofmemory}' '${cabal_install}' ${maxruns} 0",
    creates => $creates,
    cwd     => $cwd,
    onlyif  => $onlyif,
    unless  => $unl,
  }

  ## Remove the (older) installed Version
  exec { "ghc-pkg unregister ${title} (${name})":
    command => "ghc-pkg unregister --force ${name}-\$(${version})",
    onlyif  => $onlyif,
    unless  => ["test \$(${basicfilter} | wc -l) -lt 2", $unl],
    require => Exec["cabal install ${title} (${name})"],
  }
}
