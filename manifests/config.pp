class supervisor::config(
  $content
) {
  $dir_ensure         = $supervisor::dir_ensure
  $file_ensure        = $supervisor::file_ensure
  $recurse_config_dir = $supervisor::recurse_config_dir
  $enable_logrotate   = $supervisor::enable_logrotate

  file { $supervisor::conf_dir:
    ensure  => $dir_ensure,
    purge   => true,
    recurse => $recurse_config_dir,
  }

  file { [
    '/var/log/supervisor',
    '/var/run/supervisor'
  ]:
    ensure  => $dir_ensure,
    purge   => true,
    backup  => false,
  }

  # http://supervisord.org/running.html
  file { '/etc/sysconfig/supervisord':
    ensure  => present,
    content => "OPTIONS=\"--configuration=$supervisor::conf_file\"",
    mode    => '0644',
  }

  file { $supervisor::conf_file:
    ensure  => $file_ensure,
    content => $content,
    require => [
      File[$supervisor::conf_dir],
      File['/etc/sysconfig/supervisord']
    ],
  }

  file { '/etc/init.d/supervisord':
    ensure  => present,
    mode    => '0755',
    content => template('supervisor/supervisord.erb')
  }
}