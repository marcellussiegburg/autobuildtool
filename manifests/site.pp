###  (c) Marcellus Siegburg, 2013, License: GPL
Exec {
  path        =>
    [ '/home/vagrant/.cabal/bin', '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/',
      '/usr/local/sbin/', '/usr/local/bin/' ],
  environment => 'HOME=/home/vagrant',
  logoutput   => on_failure,
  user        => 'vagrant',
  timeout     => 0,
}

node default {
  include apache
  include mysql
  include haskell
  include git
  include autotool
  include emacs

  stage { 'test':
  }

  Stage['main'] -> Stage['test']

  class { 'test':
    stage => 'test',
  }

  package { 'emacs':
    ensure => latest,
  }

  package { 'make':
    ensure => latest,
    before =>
      [ Class['haskell'],
        Class['autotool'] ],
  }

  file { '/home/vagrant':
    ensure  => directory,
    name    => '/home/vagrant',
    group   => 'vagrant',
    owner   => 'vagrant',
    recurse => true,
    before  =>
      [ Class['apache'],
        Class['mysql'],
        Class['haskell'],
        Class['git'],
        Class['autotool'] ],
  }

  package { 'w3m':
    ensure => latest,
    name   => 'w3m',
    before => Class['test'],
  }
}
