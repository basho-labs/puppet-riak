#!/bin/bash
set -e

# this runs each of the major platform beaker tests
# this script will run the virtualbox versions of these tests

BEAKER_set=centos-66-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=centos-7-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=debian-78-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=ubuntu-server-1204-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
BEAKER_set=ubuntu-server-1404-x64 BEAKER_destroy=onpass BEAKER_provision=yes bundle exec rake beaker
