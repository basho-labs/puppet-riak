class riak::config {
  file { '/etc/riak/app.config':
    ensure => present,
    source => 'puppet:///modules/riak/app.config'
  }
}