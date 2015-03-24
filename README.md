# Puppet module for Riak

This module allows you to manage Riak with Puppet.

## Description

[Riak](http://basho.com/riak/) is an open source, distributed database that
focuses on high availability, horizontal scalability, and *predictable*
latency.

This repository is **community supported**. We both appreciate and need your contribution to keep it stable. For more on how to contribute, [take a look at the contribution process](#contribution).

Thank you for being part of the community! We love you for it. 

## Getting Started

**Have a look at the [Wiki][2].**

### Tested on:

 * Ubuntu 12.04 LTS (Precise) 64-bit - works, 
 * Debian 6.0 (Squeeze) 64-bit
 * CentOs 6.3 64-bit

## Development Environment

You can simply clone this module like normal to your puppet-modules-folder.
It'll work. Done.

If you want to check that it works, then install `vagrant`, `rake` and
`VirtualBox`, then run `rake vagrant:up`.

----

**For more details info, see [Testing with Vagrant][3] on the wiki.**

### Outstanding External Issues

Working on this module has been really nice, but unfortunately it's
noticeable that not most people actually unit-test their puppet modules.

I think puppet is an awesome project, and I would love for the tooling
around creating powerful modules to improve. Here are some of my experienced
bumps in the road.

 * https://github.com/rodjek/rspec-puppet/issues/44

   This issue affects the tests, making them impossible to run cleanly
   together at the moment. The only way around it, is to launch rspec
   first for `classes`, then for `functions`.

 * https://github.com/amfranz/rspec-hiera-puppet/issues/3

   This issue affects a single test that exposed the issue; overriding
   puppet variables with rspec variables. The test is currently marked as
   pending.


[2]: https://github.com/basho/puppet-riak/wiki
[3]: https://github.com/basho/puppet-riak/wiki/Testing-with-Vagrant

##Contributions 

Basho Labs repos survive because of community contribution. Here’s how to get started.

* Fork the appropriate sub-projects that are affected by your change
* Create a topic branch for your change and checkout that branch
     git checkout -b some-topic-branch
* Make your changes and run the test suite if one is provided (see below)
* Commit your changes and push them to your fork
* Open a pull request for the appropriate project
* Contributors will review your pull request, suggest changes, and merge it when it’s ready and/or offer feedback
* To report a bug or issue, please open a new issue against this repository

### Maintainers
* Henrik Feldt (@haf)
* and You! [Read up](https://github.com/basho-labs/the-riak-community/blob/master/config-mgmt-strategy.md) and get involved

You can [read the full guidelines](http://docs.basho.com/riak/latest/community/bugs/) for bug reporting and code contributions on the Riak Docs. And **thank you!** Your contribution is incredible important to us.
