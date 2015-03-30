This module has grown over time based on a range of contributions from
people using it. If you follow these contributing guidelines your patch
will likely make it into a release a little quicker.


## Contributing

1. Fork the repo.

2. [Install dependencies](#dependencies)

2. [Run the tests](#how-to-run-tests). We only take pull requests with passing tests, and
   it's great to know that you have a clean slate.

3. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.

4. Make the test pass.

5. Push to your fork and submit a pull request.


## Dependencies

The testing and development tools have a bunch of dependencies,
all managed by [Bundler](http://bundler.io/) according to the
[Puppet support matrix](http://docs.puppetlabs.com/guides/platforms.html#ruby-versions).

By default the tests use a baseline version of Puppet. This module does not support Puppet versions prior to 3.7.

You should probably use [rvm](https://rvm.io/rvm/install) to maintain separate Ruby environments for each project you work on. If you don't have it, install it first.


Install the dependencies like so...

    bundle install

To run beaker tests, you'll need to install [vagrant](https://www.vagrantup.com) and [virtualbox](https://www.virtualbox.org/). Once those are installed, install some useful vagrant plugins:

```bash
vagrant plugin install vagrant-vbguest vagrant-cachier vagrant-auto_network vagrant-hosts
```

If you're using vagrant with VMWare, you're on your own. I haven't had much luck with it, but it can probably work if you know what you're doing. The beaker tests assume that virtualbox will be the provider, and you may need to disable / uninstall the vagrant vmware plugin.

One the dependencies above are satisfied, you can run [rspec-puppet](http://rspec-puppet.com) tests and [beaker](https://github.com/puppetlabs/beaker) tests. The rspec-puppet tests are quick unit tests that should be run frequently, and the beaker tests spin up a whole virtual machine to do integration testing, so they take a long time (sometimes 10+ minutes) to run.


## Syntax and style

The test suite will run [Puppet Lint](http://puppet-lint.com/) and
[Puppet Syntax](https://github.com/gds-operations/puppet-syntax) to
check various syntax and style things. You can run these locally with:

    bundle exec rake lint
    bundle exec rake syntax

## Running the unit tests

The unit test suite covers most of the code, as mentioned above please
add tests if you're adding new functionality. If you've not used
[rspec-puppet](http://rspec-puppet.com/) before then feel free to ask
about how best to test your new feature. Running the test suite is done
with:

    bundle exec rake spec

If it doesn't work, you probably either need to do a bundle install first, or you may be running an unsupported Ruby version. (See README for the current supported list)

Note also you can run the syntax, style and unit tests in one go with:

    bundle exec rake test

### Automatically run the tests

During development of your puppet module you might want to run your unit
tests a couple of times. You can use the following command to automate
running the unit tests on every change made in the manifests folder.

    bundle exec guard

## Integration tests

The unit tests just check the code runs, not that it does exactly what
we want on a real machine. For that we're using
[Beaker](https://github.com/puppetlabs/beaker).

Beaker fires up a new virtual machine (using Vagrant) and runs a series of
simple tests against it after applying the module. 



To run beaker tests, first get a list of available nodesets:

```bash
bundle exec rake beaker_nodes
centos-511-x64
centos-64-x64
centos-66-x64
centos-7-x64
debian-609-x64
debian-76-x64
default
docker
fedora-20-x64
pooler_centos-6-x86_64
pooler_centos-7-x86_64
pooler_debian-7-x86_64
pooler_ubuntu-1204-x86_64
pooler_ubuntu-1404-x86_64
ubuntu-server-1204-x64
ubuntu-server-12042-x64
ubuntu-server-1404-x64
```

The nodes starting with pooler will only work if you have access to the puppet labs internal testing infrastructure, so you probably want to ignore them. To kick off beaker tests for a particular platform, run commands like the following: (probably one at a time)

```
BEAKER_set=centos-66-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=centos-7-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=debian-76-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=ubuntu-server-1204-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=ubuntu-server-1404-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
```

Here's what those options mean:

`BEAKER_destroy=onpass`: if the tests pass, beaker should destroy the virtual machine. If they don't pass, keep it so you can SSH in and troubleshoot. Other options are `yes` which means always destroy the VM even if it fails, or `no` which always keeps the VM, and you'll have to clean up manually.

`BEAKER_provision=yes`: provision a new VM each time this is run, destroying the previous one. If you ran the test using `BEAKER_destroy=onpass` but it didn't pass, you could re-run using `BEAKER_provision=no` and it would run the tests in that existing VM. Note that this may produce misleading results because it won't be a fresh test environment; there's no cleanup performed in the VM between runs.

`BEAKER_set=debian-76-x64`: use the `debian-76-x64` nodeset, which is defined in [spec/acceptance/nodesets/debian-76-x64.yml](spec/acceptance/nodesets/debian-76-x64.yml).

### My beaker tests didn't pass. Now what?

The Vagrantfile for the created virtual machines will be in `.vagrant/beaker_vagrant_files`. Each beaker vagrant environment is in its' own folder. For example, if you use the `debian-76-x64` nodeset, you'll need to:

```
cd .vagrant/beaker_vagrant_files/debian-76-x64.yml
vagrant ssh debian-76-x64
```

The puppet manifests beaker ran are in /tmp under randomly generated filenames that look something like `apply_manifest.pp.JdWRCc`. You can re-run them by using `puppet apply`. I'm not aware of a way to re-run the serverspec tests defined in the beaker tests.

Troubleshooting inside a beaker test node is a bit awkward, so unless the problem is trivial you should probably try to reproduce it in a regular vagrant environment, and work from there.


### How to use the vagrant environment

The included vagrant environment is strictly intended for development, not for a quick demo of the module. That might be added in later. See the [dependencies](#dependencies) section above for a list of vagrant plugins that should be installed.

For the most basic use case:
```
$ vagrant status
Current machine states:

puppetlabs-centos-7.0-64-puppet-1   not created (virtualbox)
puppetlabs-ubuntu-14.04-64-puppet-1 not created (virtualbox)
puppetlabs-centos-6.6-64-puppet-1   not created (virtualbox)
puppetlabs-ubuntu-12.04-64-puppet-1 not created (virtualbox)
puppetlabs-debian-7.8-64-puppet-1   not created (virtualbox)

$ vagrant up puppetlabs-debian-7.8-64-puppet-1
Bringing machine 'puppetlabs-debian-7.8-64-puppet-1' up with 'virtualbox' provider...
==> puppetlabs-debian-7.8-64-puppet-1: AutoNetwork assigning "10.20.1.74" to 'puppetlabs-debian-7.8-64-puppet-1'
==> puppetlabs-debian-7.8-64-puppet-1: Importing base box 'puppetlabs/debian-7.8-64-puppet'...
==> puppetlabs-debian-7.8-64-puppet-1: Matching MAC address for NAT networking...
<snip>
$ vagrant ssh puppetlabs-debian-7.8-64-puppet-1
Linux localhost 3.2.0-4-amd64 #1 SMP Debian 3.2.65-1+deb7u2 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
vagrant@puppetlabs-debian-7:~$ sudo -i
root@puppetlabs-debian-7:~# cd /etc/puppet/modules/riak/
root@puppetlabs-debian-7:/etc/puppet/modules/riak#
```

The git checkout of the riak module is mapped to /etc/puppet/modules/riak in the vagrant environment, and puppet module dependencies were installed automatically based on the contents of metadata.json. Simple test cases for interactive development should reside in the `tests` directory.


## Development Workflow

The ideal imagined workflow is to:

- fork and create a branch
- run rspec-puppet to make sure tests pass to begin with
- consider kicking off a beaker run here, since it takes so long, and let it run in the background while you do other things
- add an rspec-puppet test case
- re-run rspec-puppet and observe the failures
- write some puppet code to add your desired functionality
- re-run rspec-puppet and either observe it pass or go back and fix the code
- bring up a vagrant box
- add a test file in tests with the puppet code you want to apply to validate your changes
- run the test file (something like `puppet apply /etc/puppet/modules/riak/tests/init.pp`) and see what happens
- edit code (no need to redeploy, it's mapped into the vagrant box)
- if there was a logic problem, consider updating your rspec-puppet tests to cover that bit of logic
- re-run the `puppet apply`, and just iterate until your functionality works
- run the rspec-puppet tests to confirm you didn't break other thing
- consider updating beaker tests if there's new functionality being delivered that you need to integration test and can't just get in rspec-puppet.
- update docs as necessary
- commit, push to your fork, and make a pull request
