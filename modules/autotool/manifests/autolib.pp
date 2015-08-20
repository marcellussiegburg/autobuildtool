###  (c) Marcellus Siegburg, 2013, License: GPL
class autotool::autolib ($build_doc = $::autotool::build_doc) {
  $path = $::autotool::autolib_path

  Cabalinstall {
    constraints => $::autotool::dependencies::dependency_constraints,
    build_doc   => $build_doc,
    cwd         => $::autotool::install_path,
  }

  cabalinstall { 'autolib-cgi':
    path   => "${path}/cgi",
    onlyif => "test -d ${path}/cgi",
    unless => 'cabal list --installed --simple-output | grep autolib-cgi',
  }

  cabalinstall { 'autolib-derive':
    path   => "${path}/derive",
    onlyif => "test -d ${path}/derive",
    unless => 'cabal list --installed --simple-output | grep autolib-derive',
  }

  cabalinstall { 'autolib-todoc':
    path    => "${path}/todoc",
    require => Cabalinstall['autolib-derive'],
    onlyif  => "test -d ${path}/todoc",
    unless  => 'cabal list --installed --simple-output | grep autolib-todoc',
  }

  cabalinstall { 'autolib-reader':
    path    => "${path}/reader",
    require =>
      [ Cabalinstall['autolib-derive'],
        Cabalinstall['autolib-todoc'] ],
    onlyif  => "test -d ${path}/reader",
    unless  => 'cabal list --installed --simple-output | grep autolib-reader',
  }

  cabalinstall { 'autolib-data':
    path    => "${path}/data",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'] ],
    onlyif  => "test -d ${path}/data",
    unless  => 'cabal list --installed --simple-output | grep autolib-data',
  }

  cabalinstall { 'autolib-util':
    path    => "${path}/util",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'] ],
    onlyif  => "test -d ${path}/util",
    unless  => 'cabal list --installed --simple-output | grep autolib-util',
  }

  cabalinstall { 'autolib-output':
    path    => "${path}/output",
    require => Cabalinstall['autolib-todoc'],
    onlyif  => "test -d ${path}/output",
    unless  => 'cabal list --installed --simple-output | grep autolib-output',
  }

  cabalinstall { 'autolib-reporter':
    path    => "${path}/reporter",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-output'] ],
    onlyif  => "test -d ${path}/reporter",
    unless  => 'cabal list --installed --simple-output | grep autolib-reporter',
  }

  cabalinstall { 'autolib-dot':
    path    => "${path}/dot",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-output'],
        Cabalinstall['autolib-reporter'] ],
    onlyif  => "test -d ${path}/dot",
    unless  => 'cabal list --installed --simple-output | grep autolib-dot',
  }

  cabalinstall { 'autolib-algorithm':
    path    => "${path}/algorithm",
    require => Cabalinstall['autolib-data'],
    onlyif  => "test -d ${path}/algorithm",
    unless  => 'cabal list --installed --simple-output | grep autolib-algorithm',
  }

  cabalinstall { 'autolib-relation':
    path    => "${path}/relation",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-algorithm'] ],
    onlyif  => "test -d ${path}/relation",
    unless  => 'cabal list --installed --simple-output | grep autolib-relation',
  }

  cabalinstall { 'autolib-fa':
    path    => "${path}/fa",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-dot'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'] ],
    onlyif  => "test -d ${path}/fa",
    unless  => 'cabal list --installed --simple-output | grep autolib-fa',
  }

  cabalinstall { 'autolib-genetic':
    path    => "${path}/genetic",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'] ],
    onlyif  => "test -d ${path}/genetic",
    unless  => 'cabal list --installed --simple-output | grep autolib-genetic',
  }

  cabalinstall { 'autolib-tex':
    path    => "${path}/tex",
    require => Cabalinstall['autolib-todoc'],
    onlyif  => "test -d ${path}/tex",
    unless  => 'cabal list --installed --simple-output | grep autolib-tex',
  }

  cabalinstall { 'autolib-rewriting':
    path    => "${path}/rewriting",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-tex'] ],
    onlyif  => "test -d ${path}/rewriting",
    unless  => 'cabal list --installed --simple-output | grep autolib-rewriting',
  }

  cabalinstall { 'autolib-transport':
    path    => "${path}/transport",
    require => Cabalinstall['autolib-derive'],
    onlyif  => "test -d ${path}/transport",
    unless  => 'cabal list --installed --simple-output | grep autolib-transport',
  }

  cabalinstall { 'autolib-graph':
    path    => "${path}/graph",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-dot'],
        Cabalinstall['autolib-transport'] ],
    onlyif  => "test -d ${path}/graph",
    unless  => 'cabal list --installed --simple-output | grep autolib-graph',
  }

  cabalinstall { 'autolib-exp':
    path    => "${path}/exp",
    require =>
      [ Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'] ],
    onlyif  => "test -d ${path}/exp",
    unless  => 'cabal list --installed --simple-output | grep autolib-exp',
  }

  cabalinstall { 'autolib-fta':
    path    => "${path}/fta",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-rewriting'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-algorithm'],
        Cabalinstall['autolib-dot'] ],
    onlyif  => "test -d ${path}/fta",
    unless  => 'cabal list --installed --simple-output | grep autolib-fta',
  }

  cabalinstall { 'autolib-foa':
    path    => "${path}/foa",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-algorithm'],
        Cabalinstall['autolib-exp'],
        Cabalinstall['autolib-dot'] ],
    onlyif  => "test -d ${path}/foa",
    unless  => 'cabal list --installed --simple-output | grep autolib-foa',
  }

  cabalinstall { 'autolib-logic':
    path    => "${path}/logic",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'] ],
    onlyif  => "test -d ${path}/logic",
    unless  => 'cabal list --installed --simple-output | grep autolib-logic',
  }

  cabalinstall { 'autolib-lib':
    path    => "${path}/lib",
    file    => "${path}/lib/autolib.cabal",
    require =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-tex'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-output'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-algorithm'],
        Cabalinstall['autolib-exp'],
        Cabalinstall['autolib-logic'],
        Cabalinstall['autolib-rewriting'],
        Cabalinstall['autolib-fta'],
        Cabalinstall['autolib-graph'],
        Cabalinstall['autolib-genetic'],
        Cabalinstall['autolib-dot'] ],
    onlyif  => "test -d ${path}/lib",
    unless  => 'cabal list --installed --simple-output | grep "autolib "',
  }
}
