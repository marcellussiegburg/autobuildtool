###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell {
  include haskell::ghc
  include haskell::cabal

  exec { 'cabal update':
    command => "cabal update",
    cwd => "/home/vagrant/",
    require => [ Class["ghc"], Class["cabal"] ],
    user => "vagrant",
  }
}
