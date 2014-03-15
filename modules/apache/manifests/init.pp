###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class apache ($apache) {
  package { $apache:
    ensure => latest,
  }

  service { $apache:
    ensure  => running,
    require => Package[$apache],
  }
}
