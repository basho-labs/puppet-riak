# == Class riak::repository::el
#
# Install the correct package repository for an EL distribution
# CentOS / RedHat / etc
#
class riak::repository::el {
  exec {  'import-packagecloud_gpgkey':
    path      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command   => 'rpm --import https://packagecloud.io/gpg.key',
    unless    => 'rpm -q gpg-pubkey | grep gpg-pubkey-d59097ab-52d46e88',
    logoutput => 'on_failure',
  }
  yumrepo { 'basho_riak':
    baseurl   => "https://packagecloud.io/basho/riak/el/${::operatingsystemmajrelease}/${::architecture}",
    descr     => 'Riak packages distributed by Basho',
    enabled   => '1',
    gpgcheck  => '0', # the rpm isn't signed, see https://github.com/basho/riak/issues/714
    gpgkey    => 'https://packagecloud.io/gpg.key',
    sslverify => '1',
    before    => Package[$::riak::package_name],
    require   => Exec['import-packagecloud_gpgkey'],
  }
}
