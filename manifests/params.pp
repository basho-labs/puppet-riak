class riak::params {

  $download_os = $::operatingsystem ? {
    /(centos|redhat)/ => 'rhel/6',
    'ubuntu'          => 'ubuntu/precise',
    'debian'          => 'ubuntu/precise',
    default           => 'ubuntu/precise'
  }

  case $::operatingsystem {
    'centos','redhat': {
      $architecture = 'el6.x86_64'
      $package = 'riak'
      $package_type = 'rpm'
    }
    'ubuntu', 'debian', default: {
      # fail: http://wiki.basho.com/Installing-on-RHEL-and-CentOS.html
      # - no 32 bit version
      $architecture = 'amd64'
      $package = 'riak'
      $pacakge_type = 'deb'
    }
  }

  $version = '1.2.0'

  $download_base = "http://downloads.basho.com.s3-website-us-east-1.amazonaws\
.com/riak/CURRENT/$download_os"

  $download_package = "${$download_base}/riak_${$version}-1_${architecture}\
.${$package_type}"

}