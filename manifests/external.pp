define backuppc::external (
  $service,
  $topdir,

  $full_period      = 6.97,
  $incr_period      = 0.97,
  $keep_full        = 1,
  $keep_incr        = 6,
  $maxage_full      = 90,
  $maxage_incr      = 30,
  $maxage_partial   = 3,
  $only             = undef,
  $exclude          = undef,
  $pinglimit        = 3,
  $blackoutcount    = 7,
  $xfer_method      = 'rsync',
  $xfer_loglevel    = 1,

  $rsyncsharename    = '/',

  $smbsharename      = ['C$'],
  $smbshareusername  = '',
  $smbsharepasswd    = '',

  $backupfileexclude = [],  # ignore '\\\\pagefile.sys' for Windows or whole backup might break :/

  $hostname = $name,
  $username = 'backup',

  $custom_config = {},
) {
  @concat::fragment { "backuppc_host_${hostname}":
    target  => '/etc/backuppc/hosts',
    content => "${hostname} 0 ${username}\n",
    notify  => Service[$service],
    tag     => "backuppc_hosts"
  }

  @file { "${topdir}/pc/${hostname}":
    ensure  => directory,
    owner   => 'backuppc',
    group   => 'backuppc',
    mode    => '0750',
    require => Package['backuppc'],
    tag     => "backuppc_pc",
  }

  @file { "${topdir}/pc/${hostname}/config.pl":
    ensure  => present,
    content => template("${module_name}/external_host.pl.erb"),
    owner   => 'backuppc',
    group   => 'www-data',
    mode    => '0740',
    notify  => Service[$service],
    require => Package['backuppc'],
    tag     => "backuppc_config"
  }

}
