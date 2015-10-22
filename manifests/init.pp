# Class: backuppc
#
# This module manages backuppc
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class backuppc (
  $ext_hosts      = {}
) inherits backuppc::params {
  include concat::setup

  # Set up dependencies
  Package[$package] -> File[$config] -> Service[$service]

  # Include preseeding for debian packages
  case $operatingsystem {
    'ubuntu', 'debian': {
      include backuppc::debian
    }
  }

  # BackupPC package and service configuration
  package { $package:
    ensure  => installed,
  }

  service { $service:
    ensure    => running,
    hasstatus => false,
    pattern   => 'BackupPC'
  }

  file { $config:
    ensure  => present,
    owner   => 'backuppc',
    group   => 'www-data',
    mode    => '0644',
    # content => template("${module_name}/config.pl"),
    require => Package[$package]
  }

  file { $config_directory:
    ensure  => present,
    owner   => 'backuppc',
    group   => 'www-data',
    require => Package[$package]
  }

  exec { 'backuppc-ssh-keygen':
    command => "/usr/bin/ssh-keygen -f ${topdir}/.ssh/id_rsa -C 'BackupPC on ${::fqdn}' -N ''",
    user    => 'backuppc',
    creates => "${topdir}/.ssh/id_rsa",
    require => Package[$package]
  }

  # Export backuppc's authorized key to all clients
  @@ssh_authorized_key { "backuppc_${::fqdn}":
    ensure  => present,
    key     => $::backuppc_pubkey_rsa,
    name    => "backuppc_${::fqdn}",
    user    => 'backup',
    options => [
      "from=\"${::ipaddress}\"",
      'command="/var/backups/backuppc.sh"'
    ],
    type    => 'ssh-rsa',
    tag     => "backuppc",
  }

  # Hosts
  concat { '/etc/backuppc/hosts':
    owner => 'backuppc',
    group => 'backuppc',
    mode  => 0750,
    require => Package[$package]
  }

  # get ssh hostkeys from puppet to avoid 'Unable to read 4 bytes' error in backuppc
  class { 'ssh::client': }

  concat::fragment { 'hosts_header':
    target  => '/etc/backuppc/hosts',
    content => "host        dhcp    user    moreUsers    # <--- do not edit this line\n",
    order   => 01,
  }

  # exported resources from other hosts
  File <<| tag == "backuppc_pc" |>>
  File <<| tag == "backuppc_config" |>>
  Concat::Fragment <<| tag == "backuppc_hosts" |>>

  # virtual resources for externally defines hosts
  $external_defaults = {
    'topdir'  => $topdir,
    'service' => $service,
  }
  create_resources("backuppc::external", $ext_hosts, $external_defaults)
  File <| tag == "backuppc_pc" |>
  File <| tag == "backuppc_config" |>
  Concat::Fragment <| tag == "backuppc_hosts" |>

  Concat <<| tag == "backuppc_exclude" |>>
  Concat::Fragment <<| tag == "backuppc_exclude" |>>
}
