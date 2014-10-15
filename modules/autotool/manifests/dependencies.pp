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
  $get_deps = 'cabal install --only-dependencies --dry-run'
  $tmp = '/home/vagrant/tmp_packages'
  $packages = '/home/vagrant/packages'

  exec { 'get dependencies':
    command => "${get_deps} ${autolib_packages} ${autotool_packages} > ${tmp}",
    cwd     => "/home/vagrant",
  }

  exec { 'extract packages':
    command => "grep -v 'Resolving dependencies...' ${tmp} | grep -v 'In order' > ${packages}",
    cwd     => "/home/vagrant",
    require => Exec['get dependencies'],
  }

  file { $tmp:
    ensure  => absent,
    require => Exec['extract packages'],
  }

  exec { 'install dependencies':
    command => "cabal install ${doc} ${libs} \$(sed 's/(latest: .\\+)//g' ${packages})",
    cwd     => "/home/vagrant",
    require => Exec['extract packages'],
  }
}
