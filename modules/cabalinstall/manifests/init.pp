###  (c) Marcellus Siegburg, 2013, License: GPL
define cabalinstall (
  $path,
  $cwd = $path,
  $onlyif = undef,
  $file = "${path}/${name}.cabal",
  $unless = undef,
  $build_doc = true,
  $constraints = '',
  $maxruns = $::haskell::maxruns,
  $extra_lib_dirs = undef,
  $creates = undef) {
  ### If $unless is undefined, assume that the package is installed in the following way:
    ## Extract the Version number of the installed package found in ghc-pkg
    ## Compare it to the number in the .cabal file
  $basicfilter = "cabal list --installed --simple-output | grep -n '^${name} [[:digit:]]'"
  $filter = "${basicfilter} | head -1"
  $version = "${filter} | cut -d' ' -f2"

  if ($unless == undef) {
    $unl = "bash -Ec \"grep '^Version' ${file} | grep ' '\$(${version})'\$'\""
  } else {
    $unl = $unless
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
  ### If the Version number has changed
  ## Install the .cabal file
  $multirun = '/vagrant/modules/cabalinstall/files/multi-run.sh'
  $outofmemory = '-e "ExitFailure 9" -e "ExitFailure 11"'
  $cabal_install = "cabal install ${doc} ${libs} ${constraints} ${file}"

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
    cwd     => $cwd,
    onlyif  => $onlyif,
    unless  => ["test \$(${basicfilter} | wc -l) -lt 2", $unl],
    before  => Exec["cabal install ${title} (${name})"],
    returns => [0, 1],
  }
}
