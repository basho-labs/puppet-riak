class riak::config {
  file { '/etc/riak/app.config':
    source => 'puppet:///modules/riak/app.config',
    ensure => present
  }
}