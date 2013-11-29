define backuppc::client::exclude (
  $exclude,
  $domain = $::domain,
) {
  include backuppc::params
  include backuppc::client::params

  if ! is_array($exclude) {
    fail("exclude must be a list")
  }

  @@concat::fragment { "backuppc_exclude_${::fqdn}_${name}":
    target  => "/var/lib/backuppc/pc/${::fqdn}/exclude.list",
    content => inline_template("<%= exclude.join('\n') %>\n"),
    require => Package['backuppc'],
    tag     => "backuppc_exclude_${domain}"
  }
}
