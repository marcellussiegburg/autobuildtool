###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell ($alex_version = undef, $packages = undef, $happy_version = undef,
$hscolour_version = undef, $haddock_version = undef, $maxruns = 1) {
  include haskell::ghc
  include haskell::cabal
  include haskell::cabal_install

  $ghc_unregister_user = '/vagrant/modules/haskell/files/ghc-unregister-user.sh'
  $unless_hscolour = 'ghc-pkg list hscolour | grep hscolour'
  $extra_packages = join($packages, ' ')

  Class['haskell::ghc'] -> Class['haskell::cabal']
  Class['haskell::ghc'] -> Class['haskell::cabal_install']

  exec { 'cabal update':
    command => 'cabal update',
    require =>
      [ Class['haskell::cabal'],
        Class['haskell::cabal_install'] ],
  }

  Exec['cabal update'] -> Cabalinstall::Hackage <| |>
  Exec['cabal update'] -> Cabalinstall <| |>

  Cabalinstall::Hackage['alex'] -> Cabalinstall::Hackage['happy']
  -> Cabalinstall::Hackage['hscolour'] -> Cabalinstall::Hackage['haddock']

  cabalinstall::hackage {
    'alex':
      version => $alex_version,
      unless  => $unless_hscolour;
    'happy':
      version => $happy_version,
      unless  => $unless_hscolour;
    'hscolour':
      version => $hscolour_version,
      unless  => $unless_hscolour;
    'haddock':
      version => $haddock_version,
      unless  => 'ghc-pkg list haddock | grep haddock';
  }

  if ($packages != undef) {
    Class['haskell::cabal_install'] ~> Exec['ghc-pkg remove userdb packages']

    exec { 'ghc-pkg remove userdb packages':
      command     => "bash -Ec '${ghc_unregister_user}'",
      refreshonly => true,
      require     => Exec['cabal update'],
    }

    cabalinstall::hackage { $extra_packages:
      require => Exec['ghc-pkg remove userdb packages'],
      before  => Cabalinstall::Hackage['alex'],
    }
  }
}
