class supervisor::supervisord {
  $service_ensure_real = $supervisor::service_ensure_real
  $service_enable      = $supervisor::service_enable

  service { $supervisor::params::system_service:
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasrestart => true,
    require    => [
      File[$supervisor::params::conf_file],
      Class['supervisor::package']
    ],
  }
}