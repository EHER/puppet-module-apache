define apache::vhost($ensure=running, $replace=false) {
  include apache

  $apache_sites_available = $apache::apache_sites_available
  $apache_sites_enabled = $apache::apache_sites_enabled

  if $ensure in [ present, running, absent, purged ] {
    $ensure_real = $ensure
  } else {
    fail('Valid values for ensure: present, running, absent, purged, or stopped')
  }

  $files_ensure = $ensure_real ? {
    /(absent|purged)/ => absent,
    default           => file
  }

  file {
    "/var/www/${name}":
      ensure  => directory,
      owner  => "root",
      group  => "www-data",
      mode   => 750;
    "${apache_sites_available}/${name}":
      ensure  => $files_ensure,
      source  => $source_real,
      content => $content_real,
      replace => $replace;
    "${apache_sites_enabled}/${name}":
      ensure => $ensure ? {
        enabled => symlink,
        default => $ensure
      },
      target => "${apache_sites_available}/${name}",
      notify => Service['apache'];
  }
}
