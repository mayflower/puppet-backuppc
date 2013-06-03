class backuppc::apache inherits backuppc::params {
  package { 'apache2':
    ensure => installed,
  }
  service { 'apache2':
    ensure => running,
  }
  file { $config_apache:
    ensure  => symlink,
    target  => '/etc/backuppc/apache.conf',
    require => Package[$package],
    notify  => Service['apache2'],
  }
}
