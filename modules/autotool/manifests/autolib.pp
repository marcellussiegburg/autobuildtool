class autotool::autolib ($build_doc = $autotool::build_doc) {
  include apache

  exec { 'git clone autolib':
    command => 'git clone git://autolat.imn.htwk-leipzig.de/git/autolib /home/vagrant/autolib',
    cwd => '/vagrant',
    user => 'vagrant',
    unless => 'test -d /home/vagrant/autolib',
  }
  
  exec { 'checkout autolib':
    command => 'git checkout remotes/origin/release',
    cwd => '/home/vagrant/autolib',
    user => 'vagrant',
    require => Exec['git clone autolib'],
    unless => 'cabal list --installed --simple-output | grep "autolib "',
  }
  
  exec { 'git fetch autolib':
    command => 'git fetch',
    cwd => '/home/vagrant/autolib',
    user => 'vagrant',
    require => Exec['git clone autolib'],
    before => Exec['checkout autolib'],
  }

  cabalinstall { 'autolib-cgi':
    cwd => '/home/vagrant/autolib/cgi',
    build_doc => $build_doc,
    require => Exec['checkout autolib'],
    onlyif => 'test -d /home/vagrant/autolib',
    unless => 'cabal list --installed --simple-output | grep autolib-cgi',
  }
  
  cabalinstall { 'autolib-derive':
    cwd     => '/home/vagrant/autolib/derive',
    build_doc => $build_doc,
    require => Exec['checkout autolib'],
    onlyif  => 'test -d /home/vagrant/autolib/derive',
    unless => 'cabal list --installed --simple-output | grep autolib-derive',
  }

  cabalinstall { 'autolib-todoc':
    cwd     => '/home/vagrant/autolib/todoc',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-derive'] ],
    onlyif  => 'test -d /home/vagrant/autolib/todoc',
    unless => 'cabal list --installed --simple-output | grep autolib-todoc',
  }

  cabalinstall { 'autolib-reader':
    cwd     => '/home/vagrant/autolib/reader',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-derive'],
        Cabalinstall['autolib-todoc'] ],
    onlyif  => 'test -d /home/vagrant/autolib/reader',
    unless => 'cabal list --installed --simple-output | grep autolib-reader',
  }

  cabalinstall { 'autolib-data':
    cwd     => '/home/vagrant/autolib/data',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'] ],
    onlyif  => 'test -d /home/vagrant/autolib/data',
    unless => 'cabal list --installed --simple-output | grep autolib-data',
  }

  cabalinstall { 'autolib-util':
    cwd     => '/home/vagrant/autolib/util',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'] ],
    onlyif  => 'test -d /home/vagrant/autolib/util',
    unless => 'cabal list --installed --simple-output | grep autolib-util',
  }

  cabalinstall { 'autolib-output':
    cwd     => '/home/vagrant/autolib/output',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'] ],
    onlyif  => 'test -d /home/vagrant/autolib/output',
    unless => 'cabal list --installed --simple-output | grep autolib-output',
  }

  cabalinstall { 'autolib-reporter':
    cwd     => '/home/vagrant/autolib/reporter',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-output'] ],
    onlyif  => 'test -d /home/vagrant/autolib/reporter',
    unless => 'cabal list --installed --simple-output | grep autolib-reporter',
  }
 
  cabalinstall { 'autolib-dot':
    cwd     => '/home/vagrant/autolib/dot',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-output'],
        Cabalinstall['autolib-reporter'] ],
    onlyif  => 'test -d /home/vagrant/autolib/dot',
    unless => 'cabal list --installed --simple-output | grep autolib-dot',
  }

  cabalinstall { 'autolib-algorithm':
    cwd     => '/home/vagrant/autolib/algorithm',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-data'] ],
    onlyif  => 'test -d /home/vagrant/autolib/algorithm',
    unless => 'cabal list --installed --simple-output | grep autolib-algorithm',
  }

  cabalinstall { 'autolib-relation':
    cwd     => '/home/vagrant/autolib/relation',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-algorithm'] ],
    onlyif  => 'test -d /home/vagrant/autolib/relation',
    unless => 'cabal list --installed --simple-output | grep autolib-relation',
  }

  cabalinstall { 'autolib-fa':
    cwd     => '/home/vagrant/autolib/fa',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-dot'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'] ],
    onlyif  => 'test -d /home/vagrant/autolib/fa',
    unless => 'cabal list --installed --simple-output | grep autolib-fa',
  }

  cabalinstall { 'autolib-genetic':
    cwd     => '/home/vagrant/autolib/genetic',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'] ],
    onlyif  => 'test -d /home/vagrant/autolib/genetic',
    unless => 'cabal list --installed --simple-output | grep autolib-genetic',
  }

  cabalinstall { 'autolib-tex':
    cwd     => '/home/vagrant/autolib/tex',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'] ],
    onlyif  => 'test -d /home/vagrant/autolib/tex',
    unless => 'cabal list --installed --simple-output | grep autolib-tex',
  }

  cabalinstall { 'autolib-rewriting':
    cwd     => '/home/vagrant/autolib/rewriting',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-tex'] ],
    onlyif  => 'test -d /home/vagrant/autolib/rewriting',
    unless => 'cabal list --installed --simple-output | grep autolib-rewriting',
  }

  cabalinstall { 'autolib-transport':
    cwd     => '/home/vagrant/autolib/transport',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-derive'] ],
    onlyif  => 'test -d /home/vagrant/autolib/transport',
    unless => 'cabal list --installed --simple-output | grep autolib-transport',
  }

  cabalinstall { 'autolib-graph':
    cwd     => '/home/vagrant/autolib/graph',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-dot'],
        Cabalinstall['autolib-transport'] ],
    onlyif  => 'test -d /home/vagrant/autolib/graph',
    unless => 'cabal list --installed --simple-output | grep autolib-graph',
  }

  cabalinstall { 'autolib-exp':
    cwd     => '/home/vagrant/autolib/exp',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'] ],
    onlyif  => 'test -d /home/vagrant/autolib/exp',
    unless => 'cabal list --installed --simple-output | grep autolib-exp',
  }

  cabalinstall { 'autolib-fta':
    cwd     => '/home/vagrant/autolib/fta',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-rewriting'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-algorithm'],
        Cabalinstall['autolib-dot'] ],
    onlyif  => 'test -d /home/vagrant/autolib/fta',
    unless => 'cabal list --installed --simple-output | grep autolib-fta',
  }

  cabalinstall { 'autolib-foa':
    cwd     => '/home/vagrant/autolib/foa',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-data'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'],
        Cabalinstall['autolib-reporter'],
        Cabalinstall['autolib-relation'],
        Cabalinstall['autolib-algorithm'],
        Cabalinstall['autolib-exp'],
        Cabalinstall['autolib-dot'] ],
    onlyif  => 'test -d /home/vagrant/autolib/foa',
    unless => 'cabal list --installed --simple-output | grep autolib-foa',
  }

  cabalinstall { 'autolib-logic':
    cwd     => '/home/vagrant/autolib/logic',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
        Cabalinstall['autolib-reader'],
        Cabalinstall['autolib-util'],
        Cabalinstall['autolib-fa'] ],
    onlyif  => 'test -d /home/vagrant/autolib/logic',
    unless => 'cabal list --installed --simple-output | grep autolib-logic',
  }

  cabalinstall { 'autolib-lib':
    cwd     => '/home/vagrant/autolib/lib',
    build_doc => $build_doc,
    require =>
      [ Exec['checkout autolib'],
        Cabalinstall['autolib-todoc'],
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
    onlyif  => 'test -d /home/vagrant/autolib/lib',
    unless => 'cabal list --installed --simple-output | grep "autolib "',
  }
}
