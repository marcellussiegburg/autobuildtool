###  (c) Marcellus Siegburg, 2013, License: GPL
class git {
  package { 'git':
    name => "git",
    ensure => latest,
  }
}
