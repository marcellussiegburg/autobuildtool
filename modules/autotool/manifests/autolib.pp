###  (c) Marcellus Siegburg, 2013, License: GPL
class autotool::autolib ($build_doc = $::autotool::build_doc) {
  $path = $::autotool::autolib_path

  Cabalinstall {
    constraints => $::autotool::dependencies::dependency_constraints,
    build_doc => $build_doc,
  }

  cabalinstall { 'autolib-cgi':
    cwd       => "${path}/cgi",
    onlyif    => "test -d ${path}/cgi",
    unless    => 'cabal list --installed --simple-output | grep autolib-cgi',
  }

  cabalinstall { 'autolib-derive':
    cwd       => "${path}/derive",
    onlyif    => "test -d ${path}/derive",
    unless    => 'cabal list --installed --simple-output | grep autolib-derive',
  }

  cabalinstall { 'autolib-todoc':
    cwd       => "${path}/todoc",
    require   => Cabalinstall['autolib-derive'],
    onlyif    => "test -d ${path}/todoc",
    unless    => 'cabal list --installed --simple-output | grep autolib-todoc',
  }

  cabalinstall { 'autolib-reader':
    cwd       => "${path}/reader",
    require   =>
      [ Cabalinstall['autolib-derive'],
        Cabalinstall['autolib-todoc'] ],
    onlyif    => "test -d ${path}/reader",
    unless    => 'cabal list --installed --simple-output | grep autolib-reader',
  }

  cabalinstall { 'autolib-data':
    cwd       => "${path}/data",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'] ],
    onlyif    => "test -d ${path}/data",
    unless    => 'cabal list --installed --simple-output | grep autolib-data',
  }

  cabalinstall { 'autolib-util':
    cwd       => "${path}/util",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'] ],
    onlyif    => "test -d ${path}/util",
    unless    => 'cabal list --installed --simple-output | grep autolib-util',
  }

  cabalinstall { 'autolib-output':
    cwd       => "${path}/output",
    require   => Cabalinstall['autolib-todoc'],
    onlyif    => "test -d ${path}/output",
    unless    => 'cabal list --installed --simple-output | grep autolib-output',
  }

  cabalinstall { 'autolib-reporter':
    cwd       => "${path}/reporter",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-output'] ],
    onlyif    => "test -d ${path}/reporter",
    unless    => 'cabal list --installed --simple-output | grep autolib-reporter',
  }

  cabalinstall { 'autolib-dot':
    cwd       => "${path}/dot",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-output'],
        Cabalinstall['autolib-reporter'] ],
    onlyif    => "test -d ${path}/dot",
    unless    => 'cabal list --installed --simple-output | grep autolib-dot',
  }

  cabalinstall { 'autolib-algorithm':
    cwd       => "${path}/algorithm",
    require   => Cabalinstall['autolib-data'],
    onlyif    => "test -d ${path}/algorithm",
    unless    => 'cabal list --installed --simple-output | grep autolib-algorithm',
  }

  cabalinstall { 'autolib-relation':
    cwd       => "${path}/relation",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-algorithm'] ],
    onlyif    => "test -d ${path}/relation",
    unless    => 'cabal list --installed --simple-output | grep autolib-relation',
  }

  cabalinstall { 'autolib-fa':
    cwd       => "${path}/fa",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-dot'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'] ],
    onlyif    => "test -d ${path}/fa",
    unless    => 'cabal list --installed --simple-output | grep autolib-fa',
  }

  cabalinstall { 'autolib-genetic':
    cwd       => "${path}/genetic",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'] ],
    onlyif    => "test -d ${path}/genetic",
    unless    => 'cabal list --installed --simple-output | grep autolib-genetic',
  }

  cabalinstall { 'autolib-tex':
    cwd       => "${path}/tex",
    require   => Cabalinstall['autolib-todoc'],
    onlyif    => "test -d ${path}/tex",
    unless    => 'cabal list --installed --simple-output | grep autolib-tex',
  }

  cabalinstall { 'autolib-rewriting':
    cwd       => "${path}/rewriting",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-tex'] ],
    onlyif    => "test -d ${path}/rewriting",
    unless    => 'cabal list --installed --simple-output | grep autolib-rewriting',
  }

  cabalinstall { 'autolib-transport':
    cwd       => "${path}/transport",
    require   => Cabalinstall['autolib-derive'],
    onlyif    => "test -d ${path}/transport",
    unless    => 'cabal list --installed --simple-output | grep autolib-transport',
  }

  cabalinstall { 'autolib-graph':
    cwd       => "${path}/graph",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-dot'],
        Cabalinstall['autolib-transport'] ],
    onlyif    => "test -d ${path}/graph",
    unless    => 'cabal list --installed --simple-output | grep autolib-graph',
  }

  cabalinstall { 'autolib-exp':
    cwd       => "${path}/exp",
    require   =>
      [ Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'] ],
    onlyif    => "test -d ${path}/exp",
    unless    => 'cabal list --installed --simple-output | grep autolib-exp',
  }

  cabalinstall { 'autolib-fta':
    cwd       => "${path}/fta",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-rewriting'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-algorithm'],
        Cabalinstall['autolib-dot'] ],
    onlyif    => "test -d ${path}/fta",
    unless    => 'cabal list --installed --simple-output | grep autolib-fta',
  }

  cabalinstall { 'autolib-foa':
    cwd       => "${path}/foa",
    require   =>
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
    onlyif    => "test -d ${path}/foa",
    unless    => 'cabal list --installed --simple-output | grep autolib-foa',
  }

  cabalinstall { 'autolib-logic':
    cwd       => "${path}/logic",
    require   =>
      [ Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'] ],
    onlyif    => "test -d ${path}/logic",
    unless    => 'cabal list --installed --simple-output | grep autolib-logic',
  }

  cabalinstall { 'autolib-lib':
    cwd       => "${path}/lib",
    require   =>
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
    onlyif    => "test -d ${path}/lib",
    unless    => 'cabal list --installed --simple-output | grep "autolib "',
  }
}
