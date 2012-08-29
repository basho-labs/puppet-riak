# docs
class riak::appconfig(
  $cfg = hiera_hash('cfg', {
    bcd => 3,
    a   => 4
  }),
  $source = hiera('source'),
  $template = hiera('template'),
  $absent = hiera('absent', 'false')
) {

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present'
  }

  $manage_template = $template ? {
    ''      => undef,
    default => template($template)
  }

  anchor { 'riak::appconfig::start': } ->

  file { '/etc/riak/app.config':
    ensure  => $manage_file,
    content => $manage_template,
    source  => $source
  } ~>

  anchor { 'riak::appconfig::end':}
}
