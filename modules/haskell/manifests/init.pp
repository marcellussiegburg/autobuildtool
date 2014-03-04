###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell {
  include haskell::ghc
  include haskell::cabal

  exec { 'cabal update':
    command => 'cabal update',
    cwd     => '/home/vagrant/',
    require =>
      [ Class['haskell::ghc'],
        Class['haskell::cabal'] ],
    user    => 'vagrant',
  }

  exec { 'cabal install happy alex haddock hscolour':
    command => 'cabal install --enable-documentation --haddock-hyperlink-source happy alex haddock hscolour',
    cwd     => '/home/vagrant',
    require => Exec['cabal update'],
    unless  => 'ghc-pkg list haddock | grep haddock && ghc-pkg list hscolour | grep hscolour',
  }
}
