###  (c) Marcellus Siegburg, 2013, License: GPL
Exec {
  path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/sbin/", "/usr/local/bin/" ],
  environment => "HOME=/home/vagrant",
  user => "vagrant",
  timeout => 0,
}

class autotool {
  include autotool::autolib
  include autotool::tool
  include haskell
  include git

  package { 'happy':
    name => "happy",
    ensure => latest,
    before => [ Class["tool"],
                Class["autolib"] ],
    require => [ Class["haskell"],
                 Class["git"] ],
  }
}

include autotool
