#### Contents ####
1. About
2. Installation
3. Getting Started
4. A break
4.1 suspend
4.2 halt
5. Clean up
6. Additional Information

#### 1. About ####
This script will set up a virtual machine (virtualbox) and compile the latest version of autotool (http://www.imn.htwk-leipzig.de/~waldmann/autotool/) from scratch without the need of user interaction. You will be able to interact with the machine using vagrant.


#### 2. Installation ####
## Requirements ##
In order to use this script you have to install:
   VirtualBox
   vagrant

You will get VirtualBox here: https://www.virtualbox.org/wiki/Downloads
You will get Vagrant here: http://downloads.vagrantup.com/

On linux systems it might be helpful that you add /opt/vagrant/bin to your PATH.


#### 3. Getting started ####
In Terminal: Go to the folder containing this file.
   (e.g. cd ~/autobuildtool)
Now set up the virtual machine using the command
   > vagrant up
This may take a while, depending on your computer it might take some hours.

When it is completed a new virtual machine is created and running. You can interact with the machine using.
   > vagrant ssh


#### 4. A break ####
When you think it is time for a break, you have got two options:
   suspend
   halt

## 4.1 suspend ##
   > vagrant suspend
in order to continue your work use
   > vagrant resume

## 4.2 halt ##
The machine will be shut down
   > vagrant halt
in order to continue your work use
   > vagrant up
The whole system will reboot.

#### 5. Clean up ####
When you are done with your work. You can easily destroy the machine by entering
   > vagrant destroy

Note: This will tear down the virtual machine and completely remove it. That means all data entered or changed on the virtual machine will be lost.

On creation vagrant downloaded a box. In order to remove it use
   > vagrant box remove precise32

Note: If you choose to use the 64-bit system instead you may have to use
   > vagrant box remove precise64


#### 6. Additional information ####
By default the script is configured to use the 64-bit precise edition of the vagrant box. It might be possible that your machine is not starting because your machine does not support 64-bit guests. It might be a missing setting in your BIOS. However you are able to use the 32-bit precise edition instead by renaming your current Vagrantfile and afterwards renaming the file Vagrantfile-i386 to Vagrantfile before you create the machine by using "vagrant up".

You may use any other Ubuntu vagrant box, if you like to do so, in order to use this as your base for the autotool setup. You just need to modify the file Vagrantfile according to your needs.
Please note that the script does not support other vagrant boxes than Ubuntu. Although it might work with some other virtual machines as well it is unlikely and was not tested.
