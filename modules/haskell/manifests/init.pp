###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell {
  include haskell::ghc
  include haskell::cabal
  include haskell::cabal_install

  Class['haskell::ghc'] -> Class['haskell::cabal']
  Class['haskell::ghc'] -> Class['haskell::cabal_install']

  exec { 'cabal update':
    command => 'cabal update',
    require =>
      [ Class['haskell::cabal'],
        Class['haskell::cabal_install'] ],
  }

  exec { 'cabal install happy alex haddock hscolour':
    command => 'cabal install --enable-documentation --haddock-hyperlink-source happy alex haddock hscolour',
    require => Exec['cabal update'],
    unless  => 'ghc-pkg list haddock | grep haddock && ghc-pkg list hscolour | grep hscolour',
  }
}
