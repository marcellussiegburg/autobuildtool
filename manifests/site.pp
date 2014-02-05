###  (c) Marcellus Siegburg, 2013, License: GPL
Exec {
  path => [ "/home/vagrant/.cabal/bin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/sbin/", "/usr/local/bin/" ],
  environment => "HOME=/home/vagrant",
  logoutput => on_failure,
  user => "vagrant",
  timeout => 0,
}

node default {
  include apache
  include mysql
  include haskell
  include git
  include autotool
  include emacs

  stage { 'test':
    require => Stage["main"],
  }

  class { 'test':
    stage => "test",
  }

  if $::operatingsystem == 'ubuntu' {
    exec { 'apt-get update':
      command => "sudo /usr/bin/apt-get update --fix-missing",
      before =>
        [ Class["apache"],
          Class["mysql"],
          Class["haskell"],
          Class["git"],
          Class["autotool"],
          Class["emacs"] ],
    }
    Exec['apt-get update'] -> Package['make']
    Exec['apt-get update'] -> Package['w3m']
  }

  package { 'make':
    name => "make",
    ensure => latest,
    before => [ Class["haskell"],
                Class["autotool"] ],
  }

  file { '/home/vagrant':
    name => "/home/vagrant",
    ensure => directory,
    group => "vagrant",
    owner => "vagrant",
    recurse => true,
    before => [ Class["apache"],
                Class["mysql"],
                Class["haskell"],
                Class["git"],
                Class["autotool"] ],
  }

  package { 'w3m':
    name => "w3m",
    ensure => latest,
    before => Class["test"],
  }
}