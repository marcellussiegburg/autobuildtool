###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class haskell ($alex_version = undef, $git_packages = undef,
$git_path = '/home/vagrant/cabal-git', $happy_version = undef,
$hscolour_version = undef, $haddock_version = undef, $maxruns = 1,
$packages = []) {
  include haskell::ghc
  include haskell::cabal
  include haskell::cabal_install

  $ghc_unregister_user = '/vagrant/modules/haskell/files/ghc-unregister-user.sh'
  $filter_packages = '/vagrant/modules/haskell/files/filter_packages.sh'
  $packages_to_constraints = '/vagrant/modules/haskell/files/packages_to_constraints.sh'
  $unless_hscolour = 'ghc-pkg list hscolour | grep hscolour'

  Class['haskell::ghc'] -> Class['haskell::cabal']
  Class['haskell::ghc'] -> Class['haskell::cabal_install']

  exec { 'cabal update':
    command => 'cabal update',
    require =>
      [ Class['haskell::cabal'],
        Class['haskell::cabal_install'] ],
  }

  Exec['cabal update'] -> Cabalinstall::Hackage <| |>
  Exec['cabal update'] -> Cabalinstall::Git <| |>
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

  Class['haskell::cabal_install'] ~> Exec['ghc-pkg remove user packages']

  exec { 'ghc-pkg remove user packages':
    command     => "bash -Ec '${ghc_unregister_user}'",
    refreshonly => true,
    require     => Cabalinstall::Hackage['haddock'],
  }

  $packages_versioned = $packages.filter |$p| { $p =~ /-[\.\d]+$/ }
  $packages_no_version = $packages.filter |$p| { $p !~ /-[\.\d]+$/ }

  if ($git_packages != undef) {
    create_resources(cabalinstall::git, $git_packages)
    map($git_packages) |$git| {
      Exec['ghc-pkg remove user packages'] -> Cabalinstall::Git[$git[0]]
    }
  }
}
