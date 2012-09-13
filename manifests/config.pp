# == Class: riak::config

# Doing some fun stuff such as setting up the repositories

class riak::config{

  $package_repo_type = $::operatingsystem ? {
    /(?i:centos|redhat)/ => 'yum',
    /(?i:debian|ubuntu)/ => 'apt'
  }

  case $package_repo_type {
    'apt': {
        file { 
          'apt-basho':
            path   => '/etc/apt/sources.list.d/basho.list',
            content => "deb http://apt.basho.com ${lsbdistcodename} main\n"
         }
         package { 
         	'curl' : ensure => installed 
         }
         exec {
          'add-basho-key':
            command  => '/usr/bin/curl http://apt.basho.com/gpg/basho.apt.key | /usr/bin/apt-key add -',
            unless   => '/usr/bin/apt-key list | /bin/grep "Basho Technologies"',
            require  => [ Package['curl']]
         }

     }
  }
}     