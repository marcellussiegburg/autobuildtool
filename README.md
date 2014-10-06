Autobuildtool
=============

The autobuildtool will set up a virtual machine (virtualbox) and compile the latest version of autotool (<http://www.imn.htwk-leipzig.de/~waldmann/autotool/>) from scratch without the need of user interaction. After Setup it is possible to interact with the machine using vagrant.

The source code of autotool is browsable at <http://autolat.imn.htwk-leipzig.de/gitweb/?p=tool;a=summary>.

The source code of autolib, a required module of autotool is browsable at <http://autolat.imn.htwk-leipzig.de/gitweb/?p=autolib;a=summary>.

**If you come accross any errors please file a bug report here.**

Contents
--------

1. [Installation](#installation)
    2. [Preparation](#preparation)
    2. [Getting Started](#getting-started)
2. [Configuration](#configuration)
    1. [VM Configuration](#vm-config)
    2. [Autootool Configuration](#autotool-config)
    3. [Haskell Configuration](#haskell-config)
3. [A break](#a-break)
    1. [Suspend](#suspend)
    2. [Halt](#halt)
4. [Clean up](#clean-up)
5. [Additional Information](#additional-information)


<a name=installation></a>
Installation
------------

<a name=preparation></a>
### Preparation

In order to use this script you have to install:
- VirtualBox
- vagrant

You will get VirtualBox here: <https://www.virtualbox.org/wiki/Downloads>

You will get Vagrant here: <http://www.vagrantup.com/downloads.html>

On linux systems it might be helpful to add `/opt/vagrant/bin` to the PATH.


<a name=getting-started></a>
### Getting started

- Download the autobuildtool
- Switch to folder containing the repository
- And start the setup of the virtual machine using the commands

```bash
git clone git@github.com:marcellussiegburg/autobuildtool.git
cd autobuildtool
vagrant up
```

This may take a while, depending on your computer it might take longer than an hour.

When it is completed a new virtual machine is created and running. You can interact with the machine using.

```bash
vagrant ssh
```

While you interact with the machine via ssh you can use `w3m` to access the autotool website using the following command:

```bash
w3m http://localhost/cgi-bin/Super.cgi?schol=school
```

You can also access the website on your host system in the browser of your choice via <http://localhost:8080/cgi-bin/Super.cgi?school=school>.
Please note that the port number (8080) may vary if you edited your configuration file before setting up the machine, the same applies to the school at the end of the URL.

<a name=configuration></a>
Configuration
-------------

The main configuration file is [`config/congig.yaml`](config/config.yaml). You should edit this file if you want to change the behaviour of the build process or the underlying virtual machine. Basically there are three sections in the file. One section for [configuring the VM](#vm-config), one section for [Autotool Configuration](#autotool-config) and a section for [Haskell related configuration](#haskell-config).

<a name=vm-config></a>
### VM Configuration

The VM Configuration section starts with `vm` the following indented lines belong to the VM configuration.

| parameter               | description |
|:------------------------|:------------|
| `box`                   | The name of the prepacked vagrant box to be used. If no box with the specified name exists on your machine it will be downloaded from the URL specified at `box_url` |
| `box_url`               | The URL of the vagrant box to be used. Please note that only the predefined (maybe uncommented) values in [`config/congig.yaml`](config/config.yaml) are supported. Other boxes might not work or may need some additional configuration. |
| `memory`                | The size of the memory (RAM) of the virtual machine in MB. Please note: this is limited by the physical available memory on the host system. The host system itself will need some memory as well. A greater value might lead to shorter building times. |
| `swap`                  | The size of the swap space to be used. `'0'` means no swap space. This is useful, if the host system does not offer much memory and thus a lower value of `memory` has to be specified. If the sum of `memory` and `swap` is too low the building process will fail. |
| `ssh_port`              | The port number to be used on the host system to connect to the VM via SSH. This will enable remote access to the VM, if the host firewall is configured accordingly. |
| `ssh_port_auto_correct` | If the SSH port number shall be changed to another available port number, if `ssh_port` is not free on the host system. Note: if set the machine will be built even on port collisions, however `ssh_port` is not assured if set. |
| `web_port`              | The port number to be used on the host system for HTTP on the virtual machine. The autotool will be available on the host system via this port. |
| `web_port_auto_correct` | If the HTTP port number shall be changed to another available port number, if `web_port` is not free on the host system. Note: if set the machine will be built even on port collisions, however `web_port` is not assured if set. |

<a name=autotool-config></a>
### Autotool Configuration

| parameter                                      | description |
|:-----------------------------------------------|:------------|
| `autotool::build_doc`                          | If the documentation shall be built for autolib and tool. |
| `autotool::enable_highscore`                   | If the highscore shall be enabled and calculated by a cron job. |
| `autotool::autolib::build_doc`                 | If the documentation shall be built for autolib, overwrites `autotool::build_doc` |
| `autotool::sources::autolib_url`               | The URL where to fetch autolib from, might also be set to a local path in the `autobuildtool` directory. |
| `autotool::sources::autolib_branch`            | The branch to use for building autolib, might also be specified to any specific commit or tag. |
| `autotool::tool::build_doc`                    | If the documentation shall be built for tool, overwrites `autotool::build_doc` |
| `autotool::sources::tool_url`                  | The URL where to fetch tool from, might also be set to a local path in the `autobuildtool` directory. |
| `autotool::sources::tool_branch`               | The branch to use for building tool, might also be specified to any specific commit or tag. |
| `autotool::database::school_name`              | The database entry specifying the name of the institution which is using the autotool. |
| `autotool::database::school_mail_suffix`       | The database entry specifying the mail suffix email addresses of the school are using. |
| `autotool::database::minister_matrikel_number` | The database entry specifying the matrikel number (login information) of the initial autotool administrator. |
| `autotool::database::minister_email`           | The database entry specifying the email address of the initial autotool administrator. |
| `autotool::database::minister_familyname`      | The database entry specifying the family name of the initial autotool administrator. |
| `autotool::database::minister_name`            | The database entry specifying the name of the initial autotool administrator. |
| `autotool::database::minister_password`        | The initial autotool administrator password to be stored encrypted in the database. |

<a name=haskell-config></a>
### Haskell Configuration


| parameter                         | description |
|:----------------------------------|:------------|
| `haskell::ghc::version`           | The GHC version to be installed. Might be any release listed at <http://www.haskell.org/ghc/>. |
| `haskell::cabal::version`         | The cabal version to be installed. Might be any release (but latest) listed at <http://www.haskell.org/cabal/release/>. |
| `haskell::cabal_install::version` | The cabal-install version to be installed. Might be any release (but latest) listed at <http://www.haskell.org/cabal/release/>. |
| `haskell::alex_version`           | The alex version to be installed. Might be any version listed at <http://hackage.haskell.org/package/alex>. |
| `haskell::haddock_version`        | The haddock version to be installed. Might be any version listed at <http://hackage.haskell.org/package/haddock>. |
| `haskell::happy_version`          | The happy version to be installed. Might be any version listed at <http://hackage.haskell.org/package/happy>. |
| `haskell::hscolour_version`       | The hscolour version to be installed. Might be any version listed at <http://hackage.haskell.org/package/hscolour>. |
| `haskell::maxruns`                | The maximum number of cabal-install runs that shall be executed, if error messages occur that indicate low memory (useful if `memory` and `swap` ([see VM Configuration)](#vm-config)) have got low values).
| `haskell::packages`               | Additional hackage cabal packages or specific hackage cabal packages to be installed *before* every other package. Might be useful if older versions of autotool shall be installed. |
| `haskell::git_packages`           | Additional cabal packages from certain git-repository to be installed *before* every other package. Might be useful if cabal version is too old or broken. |

Example of specifying additional hackage cabal packages:

```YAML
haskell::packages:
 - containers-0.4.0.0
 - html
```

Example of specifying additional git cabal packages:
```YAML
haskell::git_packages:
  'git':
    url: 'https://github.com/jhenahan/haskell-cgi'
    branch: 'master'
    version: '3001.2.8.5'
```

Git cabal packages are specified as hashes, where the key is the name of the package and the value is a hash of attributes. These attributes are optional, but `url` is required. The attributes are:

| key              | description |
|:-----------------|:------------|
| `url`            | The url to load the packages git repository from. |
| `branch`         | The branch, commit or tag to checkout the git repository. |
| `version`        | The version of the package that will be installed (it will not be checked, if the repositories version does match the specified). |
| `extra_lib_dirs` | The path to check for additional library files while compiling the cabal package. |


<a name=stop-the-vm></a>
Stop the VM
-----------

If you do not require the machine to run now, but want to continue to use it later, you have got two options:
- suspend
- halt

To continue afterwards simply continue by using

```bash
vagrant up
```

<a name=suspend></a>
### Suspend

Will send the machine in suspension mode

```bash
vagrant suspend
```

<a name=halt></a>
### Halt

Will attempt to shut down the VM. If this fails, it will force the shutdown. Eitherways the machine will halt.
```bash
vagrant halt
```

<a name=clean-up></a>
Clean up
--------

You can destroy the machine by entering

```bash
vagrant destroy
```

**Attention**: This will tear down the virtual machine and completely remove it. That means *all data* entered or changed on the virtual machine *will be lost*.

On creation vagrant downloaded a box. In order to remove it use

```bash
vagrant box remove boxname
```

of course you should enter name of the box insead of `boxname` the name of the box can be found in ```config/config.yaml```.

<a name=additional-information></a>
Additional information
----------------------

By default the script is configured to use the 64-bit precise edition of a vagrant box. It might be possible that your machine is not starting because your machine does not support 64-bit guests. It might be a missing setting in your BIOS. However you are able to use a 32-bit edition instead by exchanging the `box_url` parameter under `vm` in [`config/config.yaml`](config/config.yaml).

You may use any other Ubuntu or CentOS vagrant box, if you like to do so, in order to use this as your base for the autotool setup. You just need to modify the [`config/config.yaml`](config/config.yaml)-File accordingly.
Please note that the script does not support other vagrant boxes than *Ubuntu* and *CentOS*. Although it might work with some other virtual machines as well it is unlikely and was not tested.

The main steps of the build process of the whole machine will be shown in the terminal, on errors the full log of the failed operation will be shown. You can also find these information in the file `build.log`, where the whole log will be put in as well.
