###  (c) Marcellus Siegburg, 2013, License: GPL
Exec {
  path        =>
    [ '/home/vagrant/.cabal/bin', '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/',
      '/usr/local/sbin/', '/usr/local/bin/' ],
  environment => 'HOME=/home/vagrant',
  logoutput   => on_failure,
  user        => 'vagrant',
  timeout     => 0,
  cwd         => '/home/vagrant',
}

File {
  backup => false,
}

node default {
  include apache
  include mysql
  include haskell
  include git
  include autotool

  stage { 'test':
  }

  class { 'test':
    stage => 'test',
  }

  Stage['main'] -> Stage['test']
  Package['make'] -> Class['haskell'] -> Class['autotool']
  Class['apache'] -> Class['autotool']
  Class['mysql'] -> Class['autotool']
  Class['git'] -> Class['autotool']

  package {
    'make':
      ensure => latest;
    'emacs':
      ensure => latest;
    'w3m':
      ensure => latest;
    'graphviz':
      ensure => latest;
  }
}
