###  (c) Marcellus Siegburg, 2013, License: GPL
class haskell ($alex_version = undef, $happy_version = undef,
$hscolour_version = undef, $haddock_version = undef, $maxruns = 1) {
  include haskell::ghc
  include haskell::cabal
  include haskell::cabal_install

  $cabal = 'cabal install --enable-documentation --haddock-hyperlink-source'
  $alex = $alex_version ? {
    undef   => "${cabal} alex",
    default => "${cabal} alex-${alex_version}",
  }
  $happy = $happy_version ? {
    undef   => "${cabal} happy",
    default => "${cabal} happy-${happy_version}",
  }
  $hscolour = $hscolour_version ? {
    undef   => "${cabal} hscolour",
    default => "${cabal} hscolour-${hscolour_version}",
  }
  $haddock = $haddock_version ? {
    undef   => "${cabal} haddock",
    default => "${cabal} haddock-${haddock_version}",
  }

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
