node riak-5 {
  package { 'hiera-puppet':
    ensure => latest
  } ~>
  class { 'riak': }
}
node riak-6 {
  package { 'hiera-puppet':
    ensure => latest
  } ~>
  class { 'riak': }
}
node riak-7 {
  package { 'hiera-puppet':
    ensure => latest
  } ~>
  class { 'riak': }
}
