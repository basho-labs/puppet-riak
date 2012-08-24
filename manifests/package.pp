class riak::package(
  $version = $riak::params::version,
  $package = $riak::params::package,
  $hash = ''
) inherits riak::params {
  $download_base = "http://downloads.basho.com.s3-website-us-east-1.amazonaws\
.com/riak/CURRENT/${$riak::params::download_os}"

  $url_source = "${$download_base}/riak_${$version}-1_\
${$riak::params::architecture}.${$riak::params::package_type}"

  $url_source_hash = "${$url_source}.sha"

  httpfile {  "/tmp/${$package}-$version.${$riak::params::package_type}":
    ensure => present,
    source => $url_source,
    hash   => $hash
  }

  package { $package:
    ensure  => installed,
    require => Httpfile["/tmp/riak-$version.${$riak::params::package_type}"]
  }
}