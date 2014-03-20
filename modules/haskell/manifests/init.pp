###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell {
  include haskell::ghc
  include haskell::cabal
  include haskell::cabal_install

  $cabal = 'cabal install --enable-documentation --haddock-hyperlink-source'
  $alex = "${cabal} alex"
  $happy = "${cabal} happy"
  $hscolour = "${cabal} hscolour"
  $haddock = "${cabal} haddock"

  Class['haskell::ghc'] -> Class['haskell::cabal']
  Class['haskell::ghc'] -> Class['haskell::cabal_install']

  exec { 'cabal update':
    command => 'cabal update',
    require =>
      [ Class['haskell::cabal'],
        Class['haskell::cabal_install'] ],
  }

  Exec[$alex] -> Exec[$happy] -> Exec[$hscolour] -> Exec[$haddock]

  exec { [$happy, $alex, $haddock, $hscolour]:
    require => Exec['cabal update'],
    unless  => 'ghc-pkg list haddock | grep haddock && ghc-pkg list hscolour | grep hscolour',
  }
}
