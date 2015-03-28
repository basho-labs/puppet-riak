# == Class: riak
#
# Full description of class riak here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class riak (
  $package_name   = $::riak::params::package_name,
  $service_name   = $::riak::params::service_name,
  $manage_package = $::riak::params::manage_package,
  $manage_repo    = $::riak::params::manage_repo,
  $version        = $::riak::params::version,
  $settings       = {},
) inherits ::riak::params {

  # basic input validation
  # when we switch to puppet 4 DSL we can use typed variables
  validate_string($package_name)
  validate_string($service_name)
  validate_bool($manage_package)
  validate_bool($manage_repo)
  validate_string($version)
  validate_hash($settings)

  if $manage_repo and $manage_package {
    include ::riak::repository
  }
  if $manage_package {
    include ::riak::install
    Package[$::riak::package_name] ~> File[$::riak::params::riak_conf]
  }
  class { '::riak::config': } ~>
  class { '::riak::service': } ->
  Class['::riak']
}
