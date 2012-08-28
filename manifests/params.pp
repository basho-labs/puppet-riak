# == Class: riak::params
#
# This class implements the module params pattern, but it's loaded using hiera
# as opposed to the 'default' usage of coding the parameter values in your
# manifest.
#
# == Usage
#
# Don't use this class directly; it's being used where it is needed
#
class riak::params {

  $package = $::operatingsystem ? {
    /(centos|redhat)/ => 'riak',
    default           => 'riak'
  }

  $package_type = $::operatingsystem ? {
    /(centos|redhat)/ => 'rpm',
    default           => 'deb'
  }

  $package_hash = ''

  $architecture = $::operatingsystem ? {
    /(centos|redhat)/ => 'el6.x86_64',
    default           => 'amd64'
  }

  $version = '1.2.0'

  $vm_args_source = ''
  $vm_args_template = 'riak/vm.args.erb'

  $source = 'z'
  $template = 'riak/app.config.erb'

  $log_dir = '/var/log/riak'
  $erl_log_dir = '/var/log/riak'
}
