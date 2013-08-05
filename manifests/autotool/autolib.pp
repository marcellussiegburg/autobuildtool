class autotool::autolib {
  include apache

  exec { 'git clone autolib':
    command => "git clone git://autolat.imn.htwk-leipzig.de/git/autolib /home/vagrant/autolib",
    cwd => "/vagrant",
    user => "vagrant",
    unless => "test -d /home/vagrant/autolib",
  }
  
  exec { 'checkout autolib':
    command => "git checkout remotes/origin/release",
    cwd => "/home/vagrant/autolib",
    user => "vagrant",
    require => Exec["git clone autolib"],
    unless => "cabal list --installed --simple-output | grep autolib"
  }

  exec { 'autolib-cgi':
    command => "cabal install",
    cwd => "/home/vagrant/autolib/cgi",
    require => Exec["checkout autolib"],
    onlyif => "test -d /home/vagrant/autolib",
    unless => "cabal list --installed --simple-output | grep autolib-cgi",
  }
  
  exec { 'forauto autolib':
    command => "/home/vagrant/autolib/forauto cabal install",
    cwd => "/home/vagrant/autolib",
    require => Exec["checkout autolib"],
    unless => "cabal list --installed --simple-output | grep autolib-util"
  }
}
