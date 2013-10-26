#### Aim of this document ####

Aim of this document is to describe decisions in the development progress. It should be replicable to understand the decisions and to change decissions in the further devolopment progress if it is required because of limitations made by earlier decisions.

#### Short argumental description of technologies ####
vagrant:
 + uses virtual machines -> sandboxed environment
 + cross platform -> not system dependend
 + sandboxed virtual machines are completely equal, that means error evaluation might be easier in future
puppet:
 + mainly (guest) system independent configuration
   (only Ubuntu is supported at the moment)
 + per default installed on vagrant boxes
 - Compilation only possible by using the resource type "exec". It is adviced to not use "exec" if possible


#### Development history ####
## VERSION 1.0 ##
 - testing "vagrant" by using the instructions on their website
 - vagrant is capable of enabling automatic configuration by using scripts
--> DECISION: vagrant
 - two options: either use "chef" or "puppet" to customize the virtual machines.
 - chef seemed to be more complex
   (later I recognised that the examples that I found were not as compareable as I expected, but I already made my decision and put a lot of work into learning puppet. That is why I did not think about chef again)
--> DECISION: puppet
--> DESIGN DECISION: every major package required will be configured in its own class, every class has its own file
 > wrong decision: use haskell-platform
 - version of ghc used by haskell-platform is to old
--> DECISION: pull ghc and cabal from repository and compile it using puppet
 - use `uname -i` for detecting hardwaremodel type in order to download and install the required version of ghc
 - enable logging and put logs into build.log
 - database is configured with standard user based on the documentation of autotool
 - refactoring: replaced forauto by many cabalinstall resource types
   - advantages:
     - only dependencies are build (it this does not change anything at the moment, tho)
     - on error more than just one cabal package might be built (more errors might be visible in the log file)
   - disadvantage:
     - manifests/autotool/autolib.pp needs to be updated if dependencies change in autolib cabal packages
