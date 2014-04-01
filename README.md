Autobuildtool
=============

The autobuildtool will set up a virtual machine (virtualbox) and compile the latest version of autotool (<http://www.imn.htwk-leipzig.de/~waldmann/autotool/>) from scratch without the need of user interaction. After Setup it is possible to interact with the machine using vagrant.

The source code of autotool is browsable at <http://autolat.imn.htwk-leipzig.de/gitweb/?p=tool;a=summary>

The source code of autolib, a required module of autotool is browsable at <http://autolat.imn.htwk-leipzig.de/gitweb/?p=autolib;a=summary>

Contents
--------

1. [Installation](#installation)
    2. [Preparation](#preparation)
    2. [Getting Started](#getting-started)
2. [Configuration](#configuration)
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

see [`config/congig.yaml`](config/config.yaml)

<a name=stop-the-vm></a>
Stop the VM
-----------

If you do not require the machine to run now, but want to continue to use it later, you have got two options:
- suspend
- halt

To continue aftwerwards simply continue by using

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
