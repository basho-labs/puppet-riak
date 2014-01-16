class riak::join (

  $host    = hiera('join_host', ''),

) inherits riak::params {

  exec { "join $host":
    command => "riak ping && riak-admin cluster join riak@$host"
    onlyif => "grep -c old_account /etc/passwd",

  }

}
