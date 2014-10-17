###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool::dependencies ($build_doc = true) {
  if ($build_doc == true) {
    $doc = '--enable-documentation --haddock-hyperlink-source'
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
  $name_version = '([[:alnum:]-]+)-([\.\d]+)$'
  $const = '--constraint=\1==\2'
  $constraints = regsubst($::haskell::packages_versioned, $name_version, $const)
  $constraint = join($constraints, ' ')
  $extra = join($::haskell::packages_no_version, ' ')
  $extras_git = map($::haskell::git_packages) |$git| {
    if has_key($git[1], 'version') {
      "${git[0]}-${git[1]['version']}"
    } else {
      $git[0]
    }
  }
  $extra_git = join(prefix($extras_git, "${::haskell::git_path}/"), ' ')
  $libs = "--extra-lib-dirs=${lib_dirs}"
  $autolib = ['lib', 'algorithm', 'cgi', 'data', 'derive', 'dot', 'exp', 'fa',
              'foa', 'fta', 'genetic', 'graph', 'logic', 'output', 'reader',
              'relation', 'reporter', 'rewriting', 'tex', 'todoc', 'transport',
              'util']
  $autotool = ['interface', 'server-interface', 'server-implementation',
               'collection', 'db']
  $autolib_paths = prefix($autolib, "${::autotool::autolib_path}/")
  $autotool_paths = prefix($autotool, "${::autotool::autotool_path}/")
  $autolib_packages = join($autolib_paths, ' ')
  $autotool_packages = join($autotool_paths, ' ')
  $get_deps = "cabal install --only-dependencies --dry-run ${constraint} ${extra} ${extra_git}"
  $tmp = '/home/vagrant/tmp_packages'
  $packages = '/home/vagrant/packages'
  $command = "cabal install ${doc} ${libs} ${extra_git}"
  # Filter: Filter Packages and Flags in output of $get_deps
  # Begin Filter
  $filters = map($::haskell::git_packages) |$git| {
    "| sed '/^${git[0]}[0-9\\.]\\+/d'"
  }
  $filter = join($filters, ' ')
  $filter_cmd = $::haskell::filter_packages
  $install_command = "${command} \$(echo \$(${filter_cmd} ${packages} ${filter}))"
  # End Filter
  $to_constraint = $::haskell::packages_to_constraints
  $dependency_constraints = "\$(echo \$(${filter_cmd} ${packages} | ${to_constraint}))"

  exec { 'get dependencies':
    command => "${get_deps} ${autolib_packages} ${autotool_packages} > ${tmp}",
    cwd     => '/home/vagrant',
  }

  exec { 'extract packages':
    command => "grep -v 'Resolving dependencies...' ${tmp} | grep -v 'In order' > ${packages}",
    cwd     => '/home/vagrant',
    require => Exec['get dependencies'],
  }

  file { $tmp:
    ensure  => absent,
    require => Exec['extract packages'],
  }

  exec { 'install dependencies':
    command => $install_command,
    cwd     => '/home/vagrant',
    require => Exec['extract packages'],
    unless  => 'grep "requested packages are already installed" ${packages}',
  }
  
  if ($::haskell::packages_versioned != []) {
    map($::haskell::packages_versioned) |$package| {
      cabalinstall::hackage { $package:
        build_doc      => $build_doc,
        extra_lib_dirs => $lib_dirs,
        require        => Exec['install dependencies'],
      }
    }
  }

  if ($::haskell::packages_no_version != []) {
    cabalinstall::hackage { join($::haskell::packages_no_version, ' '):
      build_doc      => $build_doc,
      extra_lib_dirs => $lib_dirs,
      require        => Exec['install dependencies'],
    }
  }

  if ($::haskell::git_packages != undef) {
    map($extras_git) |$git| {
      cabalinstall { $git:
        cwd            => "${::haskell::git_path}/${git}",
        build_doc      => $build_doc,
        extra_lib_dirs => $lib_dirs,
        require        => Exec['install dependencies'],
      }
      Cabalinstall[$git] -> Exec['install remaining dependencies']
    }
    exec { 'install remaining dependencies':
      command => "${command} --dependencies-only ${autolib_packages} ${autotool_packages}",
      cwd     => '/home/vagrant',
      unless  => 'grep "requested packages are already installed" ${packages}',
    }
  }
}
