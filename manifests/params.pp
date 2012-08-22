class riak::params {
  case $::operatingsystem {
    'centos','redhat': {
      $package_arch = 'amd64' # or 'x86_64'
      $package = 'riak'
    }
    'ubuntu', 'debian', default: {
      $package_arch = 'x86_64' # fail: http://wiki.basho.com/Installing-on-RHEL-and-CentOS.html - no 32 bit version
      $package = 'riak'
    }
  }
}