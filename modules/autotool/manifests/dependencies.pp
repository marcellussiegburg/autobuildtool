###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool::dependencies ($build_doc = true) {
  if ($build_doc == true) {
    $doc = "--enable-documentation $::haskell::doc_params"
  } else {
    $doc = '--disable-documentation'
  }
  case $::architecture {
    x86_64: {
      $lib_dirs = '/usr/lib64/mysql'
    }
    default: {
      $lib_dirs = '/usr/lib/mysql'
    }
  }
  $fix = '--constraint "ghc installed" --constraint "transformers installed"'
  $name_version = '([[:alnum:]-]+)-([\.\d]+)$'
  $const = '--constraint=\1==\2'
  $constraints = regsubst($::haskell::packages_versioned, $name_version, $const)
  $constraint = join($constraints, ' ')
  $extra = join($::haskell::packages_no_version, ' ')
  $libs = "--extra-lib-dirs=${lib_dirs}"
  $autolib = ['lib', 'algorithm', 'cgi', 'data', 'derive', 'dot', 'exp', 'fa',
              'foa', 'fta', 'genetic', 'graph', 'logic', 'output', 'reader',
              'relation', 'reporter', 'rewriting', 'tex', 'todoc', 'transport',
              'util']
  $autotool = ['interface', 'server-interface', 'server-implementation',
               'collection', 'db', 'yesod']
  $autolib_paths = prefix($autolib, "${::autotool::autolib_path}/")
  $autotool_paths = prefix($autotool, "${::autotool::autotool_path}/")
  $autolib_packages = join($autolib_paths, ' ')
  $autotool_packages = join($autotool_paths, ' ')
  $get_deps = "cabal install --only-dependencies --max-backjumps=-1 --dry-run ${constraint} ${fix} ${extra} ${extra_git}"
  $tmp = '/home/vagrant/tmp_packages'
  $packages = '/home/vagrant/packages'
  $command = "cabal install ${doc} ${libs} ${extra_git}"
  # Filter: Filter Packages and Flags in output of $get_deps
  # Begin Filter
  $filter_cmd = $::haskell::filter_packages
  $install_command = "${command} \$(echo \$(${filter_cmd} ${packages} ${filter}))"
  # End Filter
  $to_constraint = $::haskell::packages_to_constraints
  $dependency_constraints = "\$(echo \$(${filter_cmd} ${packages} | ${to_constraint}))"

  exec { 'get dependencies':
    command => "${get_deps} ${autolib_packages} ${autotool_packages} > ${tmp}",
    cwd     => $::autotool::install_path,
  }

  exec { 'extract packages':
    command => "grep -v 'Resolving dependencies...' ${tmp} | grep -v 'In order' > ${packages}",
    cwd     => $::autotool::install_path,
    require => Exec['get dependencies'],
  }

  file { $tmp:
    ensure  => absent,
    require => Exec['extract packages'],
  }

  exec { 'install dependencies':
    command => $install_command,
    cwd     => $::autotool::install_path,
    require => Exec['extract packages'],
    unless  => "grep 'requested packages are already installed' ${packages}",
  }
  
  if ($::haskell::packages_versioned != []) {
    map($::haskell::packages_versioned) |$package| {
      cabalinstall::hackage { $package:
        cwd            => $::autotool::install_path,
        build_doc      => $build_doc,
        extra_lib_dirs => $lib_dirs,
        require        => Exec['install dependencies'],
      }
    }
  }

  if ($::haskell::packages_no_version != []) {
    cabalinstall::hackage { join($::haskell::packages_no_version, ' '):
      cwd            => $::autotool::install_path,
      build_doc      => $build_doc,
      extra_lib_dirs => $lib_dirs,
      require        => Exec['install dependencies'],
    }
  }

  if ($::haskell::git_packages != undef) {
    $extras_git = map($::haskell::git_packages) |$git| {
      if has_key($git[1], 'version') {
        "${git[0]}-${git[1]['version']}"
      } else {
        $git[0]
      }
    }
    $extra_git = join(prefix($extras_git, "${::haskell::git_path}/"), ' ')
    map($extras_git) |$git| {
      cabalinstall { $git:
        cwd            => $::autotool::install_path,
        path           => "${::haskell::git_path}/${git}",
        build_doc      => $build_doc,
        extra_lib_dirs => $lib_dirs,
        require        => Exec['install dependencies'],
      }
      Cabalinstall[$git] -> Exec['install remaining dependencies']
    }
    $filters = map($::haskell::git_packages) |$git| {
      "| sed '/^${git[0]}[0-9\\.]\\+/d'"
    }
    $filter = join($filters, ' ')
    exec { 'install remaining dependencies':
      command => "${command} --dependencies-only ${autolib_packages} ${autotool_packages}",
      cwd     => $::autotool::install_path,
      unless  => 'grep "requested packages are already installed" ${packages}',
    }
  } else {
    $extra_git = ''
    $filter = ''
  }
}
