#!/bin/bash
set -e

# this runs each of the major platform beaker tests
# this script will only be useful for Puppet Labs employees because it relies
# on the VM pooler

BEAKER_set=pooler_debian-7-x86_64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=pooler_centos-6-x86_64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=pooler_centos-7-x86_64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=pooler_ubuntu-1204-x86_64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=pooler_ubuntu-1404-x86_64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
