# == Class: riak::limits

class riak::limits (
) {
  $ulimit = $riak::ulimit
  $limits_template = $riak::limits_template

  file { '/etc/security/limits.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($limits_template)
  }
}
