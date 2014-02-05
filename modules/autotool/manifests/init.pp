###  (c) Marcellus Siegburg, 2013, License: GPL
Exec {
  path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/sbin/", "/usr/local/bin/" , "/home/vagrant/.cabal/bin/" ],
  environment => "HOME=/home/vagrant",
  logoutput => on_failure,
  user => "vagrant",
  timeout => 0,
}

class autotool {
  include autotool::autolib
  include autotool::tool
  include haskell
  include git

  Class["git"] -> Class["haskell"]
  Class["autotool::autolib"] -> Class["autotool::tool"]
}

include autotool
