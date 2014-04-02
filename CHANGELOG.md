Autobuildtool Changelog
=======================

Aim of this document
--------------------

Aim of this document is to describe decisions in the development progress. It should be replicable to understand the decisions and to change decissions in the further devolopment progress if it is required because of limitations made by earlier decisions.

Short argumental description of technologies
--------------------------------------------

- Vagrant:  
   :+1: uses virtual machines -> **sandboxed environment**  
   :+1: cross platform -> **not system dependend**  
   :+1: sandboxed virtual machines are completely equal, that means **error evaluation is limited** to the single platform
- Puppet:  
  :+1: mainly (guest) system independent configuration (Ubuntu and CentOS are supported at the moment)  
  :+1: by default installed on Vagrant boxes  
  :-1: Compilation only possible by using the resource type "exec". It is adviced to not use "exec" if possible


Development history
-------------------

### Legend

| symbol       | meaning                                                              |
|:-------------|:---------------------------------------------------------------------|
|:point_right: | decision                                                             |
|:point_down:  | decision which is deprecated because of an other decision being made |
|:zap:         | decision which appeared to be wrong                                  |



### Version 1.0

 - testing **Vagrant** by using the instructions on their website
 - Vagrant is capable of enabling automatic configuration by using scripts

:point_right: [Vagrant](http://www.vagrantup.com/)

 - two options: either use [Chef](https://wiki.opscode.com/display/chef/Home) or [Puppet](http://puppetlabs.com/) to customize the virtual machines.
 - Chef seemed to be more complex  
   (later it was recognised that the examples evaluated were not as compareable as expected, but the decision has been made already and a lot of time was spent for puppet. That is why there is no thought about Chef again)

:point_right: [Puppet](http://puppetlabs.com/)

[:point_down:](#module "Module Layout") (**DESIGN**) *every major package* required will be configured *in its own class*, every class has its own file

:zap: use *haskell-platform*

 - version of ghc used by haskell-platform is too old

[:point_down:](#ghc "Ghc from package") pull *ghc and cabal from repository* and compile it using puppet

 - use `uname -i` for detecting hardwaremodel type in order to download and install the required version of ghc
 - enable logging via puppet and put logs into build.log
 - database is configured with standard user based on the documentation of autotool
 - refactoring: replaced forauto by many cabalinstall resource types
   - advantages:
     - only dependencies are build (it this does not change anything at the moment, tho)
     - on error more than just one cabal package might be built (more errors might be visible in the log file)
   - disadvantage:
     - manifests/autotool/autolib.pp needs to be updated if dependencies change in autolib cabal packages
 - upgrade `Vagrantfile` to Version 2 (dropping support for older Vagrant versions)
 - enable documentation building

<a name=module></a>
:point_right: (**DESIGN**) change Puppet manifests to use [Module Layout](http://docs.puppetlabs.com/puppet/latest/reference/modules_fundamentals.html)

- moving all manifest files in the according module folders

:point_right: [Hiera](http://docs.puppetlabs.com/hiera/1/index.html) as it makes it easy to create config files for puppet

 - user configuration shall only happen via config file `config/config.yaml`

<a name=ghc></a>
:point_right: install [ghc](http://www.haskell.org/ghc/dist/), [cabal](http://www.haskell.org/cabal/release/) and [cabal-install](http://www.haskell.org/cabal/release/) from package and built it as described using puppet

 - transform doc URLs to relative paths making it available from inside and outside the vm.
 - simplifiy dependencies making modules more independent
