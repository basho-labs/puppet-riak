# Puppet module for Riak

This module allows you to manage Riak with puppet.

Usage and details on puppet-y stuff, to follow. Meanwhile, how to get 
started on dev:


## Environment

Requires 64 bit server OS, because that's what Basho creates packages for.

Tested on:

 * Ubuntu 12.04 64-bit
 * Debian 6.0 64-bit
 * CentOs 6.0 64-bit
 
## Development Environment

You can simply clone this module like normal to your puppet-modules-folder. 
It'll work. Done.

If you want to check that it works, then install `vagrant`, `rake` and 
`VirtualBox`, then run `rake vagrant:up`.

----

With that out of the world. Here's how to set up the full chaboom:

 1. `git clone https://github.com/haf/puppet-riak.git`
 1. `cd puppet-riak`
 1. Install RVM and bundler. `curl -L https://get.rvm.io | bash -s stable --ruby --gems=bundler,rubygems-bundler`
 1. `rvm requirements`: follow these instructions. I'm using RMI 1.9.3.
 1. `bundle install`
 1. `gem regenerate_binstubs`
 1. `rake vagrant:up`

So what have you got now? By installing all required gems with bundler, you 
now have a complete development environment for testing puppet modules and 
manifests, including autotesting them when you change the source files.

When running `vagrant up`, you started three virtual machines that were
provisioned to run Riak, and connect all three of them together. This is 
your lab environment. You can make the `Guardfile` provision all machines
any time you change a puppet (.pp) file.

If you have ubuntu, you can start writing tests/manifests. Start the watcher
by running `guard`. Edit a spec file and watch how it runs. If you don't have
ubuntu, then look at your options at 
[guard/guard](https://github.com/guard/guard#readme).

Henrik.

### References

http://www.slideshare.net/PuppetLabs/modern-module-development-ken-barber-2012-edinburgh-puppet-camp
http://www.slideshare.net/Alvagante/puppet-modules-an-holistic-approach
http://puppetlabs.com/blog/puppet-module-bounty-logstash-riak-and-graphite/?utm_campaign=blog&utm_medium=socnet&utm_source=twitter&utm_content=modbounty1
http://puppetlabs.com/blog/the-next-generation-of-puppet-module-testing/
