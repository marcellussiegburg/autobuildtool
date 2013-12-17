###  (c) Marcellus Siegburg, 2013, License: GPL
class emacs {
  package { 'emacs':
    name => "emacs",
    ensure => latest,
  }
}
