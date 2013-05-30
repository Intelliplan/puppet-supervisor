class supervisor::config(
  $content
) {
  $dir_ensure         = $supervisor::dir_ensure
  $file_ensure        = $supervisor::file_ensure
  $recurse_config_dir = $supervisor::recurse_config_dir

  file { $supervisor::params::conf_dir:
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

  file { $supervisor::params::conf_file:
    ensure  => $file_ensure,
    content => $content,
    require => File[$supervisor::params::conf_dir],
    notify  => Service[$supervisor::params::system_service],
  }
  
  file { '/etc/init.d/supervisord':
    ensure  => present,
    mode    => '0755',
    content => template('supervisor/supervisord.erb')
  }

  file { '/etc/logrotate.d/supervisor':
    ensure  => $file_ensure,
    source  => 'puppet:///modules/supervisor/logrotate',
  }
}