class riak::package(
  $version = $riak::params::version,
  $pkgname = $riak::params::package,
  $url_source = $riak::params::url_source,
  $hash = $riak::params::url_source_hash,
  $type = $riak::params::package_type
) {
  
  httpfile {  "/tmp/riak-$version.$type":
    ensure => present,
    hash   => $hash
  }
  
  package { $pkgname:
    ensure  => installed,
    require => Httpfile["/tmp/riak-$version.$type"] 
  }
}