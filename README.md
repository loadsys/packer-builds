# Loadsys Packer Builds

<!--
[![Build Status](http://img.shields.io/travis/chef/bento.svg)][travis]

This repository contains [Packer](https://www.packer.io/) templates for building [Vagrant](https://www.vagrantup.com/) base boxes. It may be used to build other provider images in the future. It is derived from the [chef/bento](https://github.com/chef/bento) repository and mainly adds new templates and scripts. We use these boxes internally at Loadsys for our project environments.

This project is managed by Loadsys. Currently, some of the documentation files may still reference Chef and Chef team members.

## Pre-built Boxes

Boxes built from this repository's templates for publicly available platforms are currently hosted via Atlas in the [loadsys organization](https://atlas.hashicorp.com/loadsys/).

### Build Notes

- If you're using the [Vagrant VMWare Fusion](https://www.vagrantup.com/vmware) provider, using `vagrant box add --provider vmware_desktop ...` will work for these boxes. Using `--provider vmware_fusion`, will not.

#### VMWare Fusion 8, Packer, systemd

Recent Linux distributions use [systemd's logic to predictably name network devices](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/). In our scenario, this is tied to the PCI slot id. For unknown reasons, boxes built with [the default vmx config provided by packer](https://github.com/mitchellh/packer/blob/e868f9b69c995cf8a681857aa68e9be286243630/builder/vmware/iso/step_create_vmx.go#L168) use a different PCI slot id (32 instead of 33) once they got imported to VMWare Fusion 8, which results in a different device name and finally in broken networking. This issue is documented in the following places:

- <https://github.com/chef/bento/issues/554>
- <https://github.com/chef/bento/pull/545#issuecomment-202988690>
- <https://github.com/mitchellh/vagrant/issues/4590>

As a workaround we've started to provide the changed PCI slot id as a custom value with the packer definitions with Ubuntu 15.10+ and Debian 8+. However this is not yet tested, may not solve the issue and/or break compatibility with other VMWare products/versions!

<!--
## Older Boxes

The contents of this Github repository represent the current state of Bento and not every packer config that has ever existed in the Bento project. As a distribution is made end of life or a newer minor version of a distribution ships, we will remove the existing configurations. At the time of the next Bento release those deprecations will be noted in the release notes. If you'd like to build that release for some reason, your best course of action is to checkout the release tag in git and use the existing configs at their last known working state.

## Using Pre-built Boxes

Adding a bento box to vagrant:

```
$ vagrant box add bento/debian-8.6
```

Using a bento box in a Vagrantfile:

```
Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-8.6"
end
```

-->
## Requirements

- [Packer](https://www.packer.io/)
- At least one virtualization provider: Virtualbox, VMware Fusion, Parallels Desktop, etc
- A license for VMware Fusion Pro for the VMWare Fusion provider.

## Build Your Own Boxes

<!--
### Using `bento`

```
$ gem install bento-ya
```

If you use Bundler, you can add run `bundle install` from the bento repo. Prefix commands with `bundle exec` if doing so.

To build multiple templates for all providers (VirtualBox, Fusion, Parallels, etc):

```
$ bento build debian-8.6-amd64 debian-8.6-i386
```

To build a box for a single provider:

```
$ bento build --only=virtualbox-iso debian-8.6-amd64
```

## comment note: remove the \ from -\- above
-->
### Using `packer`

Templates can still be built directly by `packer`

To build a template for all providers (VirtualBox, Fusion, Parallels):

```
$ packer build debian-8.6-amd64.json
```

To build a template only for a list of specific providers:

```
$ packer build -only=virtualbox-iso debian-8.6-amd64.json
```

To build a template for all providers except a list of specific providers:

```
$ packer build -except=parallels-iso,vmware-iso debian-8.6-amd64.json
```

If you want to use a another mirror site, use the `mirror` user variable.

```
$ packer build -var 'mirror=http://ftp.jaist.ac.jp/pub/Linux/debian-cdimage/release' debian-8.6-amd64.json
```

Congratulations! You now have box(es) in the ../builds directory that you can then add to Vagrant and start testing cookbooks.

Notes:

- The box_basename can be overridden like other Packer vars with `-var 'box_basename=debian-8.6'`

<!--
### Proprietary Boxes

Mac OS X, Red Hat Enterprise Linux, and SUSE Linux Enterprise Server templates are provided. However, their ISOs are not publicly retrievable and as such, the URLs in those templates are bogus. For RHEL and SLES, substitute a server where the ISOs are hosted, using the mirror variable as above.

#### Mac OS X

To build a Mac OS X box, you will need to start with an installer for your desired version of OS X. You will then need to use [Tim Sutton's osx-vm-templates](https://github.com/timsutton/osx-vm-templates)/) to modify that installer for use by packer. The output of that build will include the location of the ISO and its checksum, which you can substitute into your `packer build` command, e.g.:

```
$ packer build -var 'iso_checksum=<checksum>' -var 'iso_url=<iso_url>' macosx-10.11.json
```

There is a known issue where [test-kitchen](http://kitchen.ci/) starts a Mac OS X box correctly, but `vagrant up` fails due to the absence of the HGFS kernel module. This is due to a silent failure during the VMware tools installation and can be corrected by installing the VMware tools on the Mac OS X box manually.

Note that, while it is possible to build OS X boxes for VirtualBox, it may not be ideal. VirtualBox provides no "guest additions" for OS X. Boxes consequently have limited networking configurability and must rely on rsync for folder syncing. VMWare, when available, is generally preferred.

### Windows

Currently the project does not include any definitions for building Windows boxes. For other approaches to building Windows boxes, please see the following community projects:

- [Mischa Taylor's Boxcutter project](https://github.com/boxcutter)
- [Vagrant Windows Boxes and Puppet](https://github.com/ferventcoder/vagrant-windows-puppet/tree/master/baseboxes)

### Special Note About Building from Windows Hosts

When building boxes from a Windows host system, you must ensure that kickstart configuration files (`ks.cfg` for RHEL based systems) and preseed files (`preseed.cfg` for Debian based systems) have Unix line endings (i.e. lines end with LF character only). Moreover, it's also a good idea to have `*.sh` scripts with Unix line endings too.

When these files have Windows line endings, the group creation can fail in the pre-seed phase and in turn, prevents the user `vagrant` to be created correctly. This ultimately results in Packer not being able to connect to the newly booted up machine with an error message that looks like this:

```
==> virtualbox-iso: Waiting for SSH to become available...
==> virtualbox-iso: Error waiting for SSH: handshake failed: ssh: unable to authenticate, attempted methods [none password], no support
```

Since Packer tries to log in with user `vagrant` but it was not created successfully in the pre-seed phase, it is unable to connect to the machine and the packaging process stops.

By default, when cloning this repository, git should normalize `ks.cfg`, `preseed.cfg` and `*.sh` to Unix line endings and `*.bat` to Windows line endings, thanks to the <.gitattributes> file in the repository. However, if it's not the case because you have overridden line-ending conversion in your own git configuration, convert the offending files so they have the correct line endings.

-->
## Bugs and Issues

Please use GitHub issues to report bugs, features, or other problems.

## License & Authors

All of the hard work was done by the [bento authors](https://github.com/chef/bento#license--authors).

Any changes by Loadsys are currently in the `cakephp` branch.

```text
Copyright 2012-2016, Chef Software, Inc. (<legal@chef.io>)
Copyright 2011-2012, Tim Dysinger (<tim@dysinger.net>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[centos_511_32_prl]: https://atlas.hashicorp.com/bento/boxes/centos-5.11-i386/versions/2.3.1/providers/parallels.box
[centos_511_32_vbox]: https://atlas.hashicorp.com/bento/boxes/centos-5.11-i386/versions/2.3.1/providers/virtualbox.box
[centos_511_32_vmware]: https://atlas.hashicorp.com/bento/boxes/centos-5.11-i386/versions/2.3.1/providers/vmware_desktop.box
[centos_511_64_prl]: https://atlas.hashicorp.com/bento/boxes/centos-5.11/versions/2.3.1/providers/parallels.box
[centos_511_64_vbox]: https://atlas.hashicorp.com/bento/boxes/centos-5.11/versions/2.3.1/providers/virtualbox.box
[centos_511_64_vmware]: https://atlas.hashicorp.com/bento/boxes/centos-5.11/versions/2.3.1/providers/vmware_desktop.box
[centos_68_32_prl]: https://atlas.hashicorp.com/bento/boxes/centos-6.8-i386/versions/2.3.1/providers/parallels.box
[centos_68_32_vbox]: https://atlas.hashicorp.com/bento/boxes/centos-6.8-i386/versions/2.3.1/providers/virtualbox.box
[centos_68_32_vmware]: https://atlas.hashicorp.com/bento/boxes/centos-6.8-i386/versions/2.3.1/providers/vmware_desktop.box
[centos_68_64_prl]: https://atlas.hashicorp.com/bento/boxes/centos-6.8/versions/2.3.1/providers/parallels.box
[centos_68_64_vbox]: https://atlas.hashicorp.com/bento/boxes/centos-6.8/versions/2.3.1/providers/virtualbox.box
[centos_68_64_vmware]: https://atlas.hashicorp.com/bento/boxes/centos-6.8/versions/2.3.1/providers/vmware_desktop.box
[centos_73_64_prl]: https://atlas.hashicorp.com/bento/boxes/centos-7.3/versions/2.3.2/providers/parallels.box
[centos_73_64_vbox]: https://atlas.hashicorp.com/bento/boxes/centos-7.3/versions/2.3.2/providers/virtualbox.box
[centos_73_64_vmware]: https://atlas.hashicorp.com/bento/boxes/centos-7.3/versions/2.3.2/providers/vmware_desktop.box
[debian_711_32_prl]: https://atlas.hashicorp.com/bento/boxes/debian-7.11-i386/versions/2.3.1/providers/parallels.box
[debian_711_32_vbox]: https://atlas.hashicorp.com/bento/boxes/debian-7.11-i386/versions/2.3.1/providers/virtualbox.box
[debian_711_32_vmware]: https://atlas.hashicorp.com/bento/boxes/debian-7.11-i386/versions/2.3.1/providers/vmware_desktop.box
[debian_711_64_prl]: https://atlas.hashicorp.com/bento/boxes/debian-7.11/versions/2.3.1/providers/parallels.box
[debian_711_64_vbox]: https://atlas.hashicorp.com/bento/boxes/debian-7.11/versions/2.3.1/providers/virtualbox.box
[debian_711_64_vmware]: https://atlas.hashicorp.com/bento/boxes/debian-7.11/versions/2.3.1/providers/vmware_desktop.box
[debian_86_32_prl]: https://atlas.hashicorp.com/bento/boxes/debian-8.6-i386/versions/2.3.1/providers/parallels.box
[debian_86_32_vbox]: https://atlas.hashicorp.com/bento/boxes/debian-8.6-i386/versions/2.3.1/providers/virtualbox.box
[debian_86_32_vmware]: https://atlas.hashicorp.com/bento/boxes/debian-8.6-i386/versions/2.3.1/providers/vmware_desktop.box
[debian_86_64_prl]: https://atlas.hashicorp.com/bento/boxes/debian-8.6/versions/2.3.1/providers/parallels.box
[debian_86_64_vbox]: https://atlas.hashicorp.com/bento/boxes/debian-8.6/versions/2.3.1/providers/virtualbox.box
[debian_86_64_vmware]: https://atlas.hashicorp.com/bento/boxes/debian-8.6/versions/2.3.1/providers/vmware_desktop.box
[fedora_24_64_prl]: https://atlas.hashicorp.com/bento/boxes/fedora-24/versions/2.3.1/providers/parallels.box
[fedora_24_64_vbox]: https://atlas.hashicorp.com/bento/boxes/fedora-24/versions/2.3.1/providers/virtualbox.box
[fedora_24_64_vmware]: https://atlas.hashicorp.com/bento/boxes/fedora-24/versions/2.3.1/providers/vmware_desktop.box
[fedora_25_64_prl]: https://atlas.hashicorp.com/bento/boxes/fedora-25/versions/2.3.1/providers/parallels.box
[fedora_25_64_vbox]: https://atlas.hashicorp.com/bento/boxes/fedora-25/versions/2.3.1/providers/virtualbox.box
[fedora_25_64_vmware]: https://atlas.hashicorp.com/bento/boxes/fedora-25/versions/2.3.1/providers/vmware_desktop.box
[freebsd_103_64_prl]: https://atlas.hashicorp.com/bento/boxes/freebsd-10.3/versions/2.3.1/providers/parallels.box
[freebsd_103_64_vbox]: https://atlas.hashicorp.com/bento/boxes/freebsd-10.3/versions/2.3.1/providers/virtualbox.box
[freebsd_103_64_vmware]: https://atlas.hashicorp.com/bento/boxes/freebsd-10.3/versions/2.3.1/providers/vmware_desktop.box
[freebsd_110_64_prl]: https://atlas.hashicorp.com/bento/boxes/freebsd-11.0/versions/2.3.1/providers/parallels.box
[freebsd_110_64_vbox]: https://atlas.hashicorp.com/bento/boxes/freebsd-11.0/versions/2.3.1/providers/virtualbox.box
[freebsd_110_64_vmware]: https://atlas.hashicorp.com/bento/boxes/freebsd-11.0/versions/2.3.1/providers/vmware_desktop.box
[leap_422_64_prl]: https://atlas.hashicorp.com/bento/boxes/opensuse-leap-42.2/versions/2.3.1/providers/parallels.box
[leap_422_64_vbox]: https://atlas.hashicorp.com/bento/boxes/opensuse-leap-42.2/versions/2.3.1/providers/virtualbox.box
[leap_422_64_vmware]: https://atlas.hashicorp.com/bento/boxes/opensuse-leap-42.2/versions/2.3.1/providers/vmware_desktop.box
[omnios_r151018_64_vbox]: https://atlas.hashicorp.com/bento/boxes/omnios-r151018/versions/2.3.1/providers/virtualbox.box
[oracle_511_32_prl]: https://atlas.hashicorp.com/bento/boxes/oracle-5.11-i386/versions/2.3.1/providers/parallels.box
[oracle_511_32_vbox]: https://atlas.hashicorp.com/bento/boxes/oracle-5.11-i386/versions/2.3.1/providers/virtualbox.box
[oracle_511_32_vmware]: https://atlas.hashicorp.com/bento/boxes/oracle-5.11-i386/versions/2.3.1/providers/vmware_desktop.box
[oracle_511_64_prl]: https://atlas.hashicorp.com/bento/boxes/oracle-5.11/versions/2.3.1/providers/parallels.box
[oracle_511_64_vbox]: https://atlas.hashicorp.com/bento/boxes/oracle-5.11/versions/2.3.1/providers/virtualbox.box
[oracle_511_64_vmware]: https://atlas.hashicorp.com/bento/boxes/oracle-5.11/versions/2.3.1/providers/vmware_desktop.box
[oracle_68_32_prl]: https://atlas.hashicorp.com/bento/boxes/oracle-6.8-i386/versions/2.3.1/providers/parallels.box
[oracle_68_32_vbox]: https://atlas.hashicorp.com/bento/boxes/oracle-6.8-i386/versions/2.3.1/providers/virtualbox.box
[oracle_68_32_vmware]: https://atlas.hashicorp.com/bento/boxes/oracle-6.8-i386/versions/2.3.1/providers/vmware_desktop.box
[oracle_68_64_prl]: https://atlas.hashicorp.com/bento/boxes/oracle-6.8/versions/2.3.1/providers/parallels.box
[oracle_68_64_vbox]: https://atlas.hashicorp.com/bento/boxes/oracle-6.8/versions/2.3.1/providers/virtualbox.box
[oracle_68_64_vmware]: https://atlas.hashicorp.com/bento/boxes/oracle-6.8/versions/2.3.1/providers/vmware_desktop.box
[oracle_73_64_prl]: https://atlas.hashicorp.com/bento/boxes/oracle-7.3/versions/2.3.1/providers/parallels.box
[oracle_73_64_vbox]: https://atlas.hashicorp.com/bento/boxes/oracle-7.3/versions/2.3.1/providers/virtualbox.box
[oracle_73_64_vmware]: https://atlas.hashicorp.com/bento/boxes/oracle-7.3/versions/2.3.1/providers/vmware_desktop.box
[travis]: https://travis-ci.org/chef/bento
[ubuntu_1204_32_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-12.04-i386/versions/2.3.1/providers/parallels.box
[ubuntu_1204_32_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-12.04-i386/versions/2.3.1/providers/virtualbox.box
[ubuntu_1204_32_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-12.04-i386/versions/2.3.1/providers/vmware_desktop.box
[ubuntu_1204_64_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-12.04/versions/2.3.1/providers/parallels.box
[ubuntu_1204_64_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-12.04/versions/2.3.1/providers/virtualbox.box
[ubuntu_1204_64_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-12.04/versions/2.3.1/providers/vmware_desktop.box
[ubuntu_1404_32_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-14.04-i386/versions/2.3.1/providers/parallels.box
[ubuntu_1404_32_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-14.04-i386/versions/2.3.1/providers/virtualbox.box
[ubuntu_1404_32_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-14.04-i386/versions/2.3.1/providers/vmware_desktop.box
[ubuntu_1404_64_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-14.04/versions/2.3.1/providers/parallels.box
[ubuntu_1404_64_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-14.04/versions/2.3.1/providers/virtualbox.box
[ubuntu_1404_64_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-14.04/versions/2.3.1/providers/vmware_desktop.box
[ubuntu_1604_32_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04-i386/versions/2.3.1/providers/parallels.box
[ubuntu_1604_32_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04-i386/versions/2.3.1/providers/virtualbox.box
[ubuntu_1604_32_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04-i386/versions/2.3.1/providers/vmware_desktop.box
[ubuntu_1604_64_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04/versions/2.3.1/providers/parallels.box
[ubuntu_1604_64_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04/versions/2.3.1/providers/virtualbox.box
[ubuntu_1604_64_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04/versions/2.3.1/providers/vmware_desktop.box
[ubuntu_1610_32_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.10-i386/versions/2.3.1/providers/parallels.box
[ubuntu_1610_32_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.10-i386/versions/2.3.1/providers/virtualbox.box
[ubuntu_1610_32_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.10-i386/versions/2.3.1/providers/vmware_desktop.box
[ubuntu_1610_64_prl]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.10/versions/2.3.1/providers/parallels.box
[ubuntu_1610_64_vbox]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.10/versions/2.3.1/providers/virtualbox.box
[ubuntu_1610_64_vmware]: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.10/versions/2.3.1/providers/vmware_desktop.box
