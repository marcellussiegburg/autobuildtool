###  (c) Marcellus Siegburg, 2013, License: GPL
Exec {
  path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/sbin/', '/usr/local/bin/' , '/home/vagrant/.cabal/bin/' ],
  environment => 'HOME=/home/vagrant',
  logoutput   => on_failure,
  user        => 'vagrant',
  timeout     => 0,
}

class autotool ($build_doc = true){
  include autotool::autolib
  include autotool::tool
  include autotool::doc
  include haskell
  include git

  Class['git'] -> Class['haskell']
  -> Class['autotool::autolib']
  -> Class['autotool::tool']
  -> Class['autotool::doc']
  Class['apache'] -> Class['autotool::doc']
}

include autotool
