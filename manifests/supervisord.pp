class supervisor::supervisord {
  $_ensure = $supervisor::service_ensure_real
  $_enable = $supervisor::service_enable

  service { $supervisor::params::system_service:
    ensure     => $_ensure,
    enable     => $_enable,
    hasrestart => true,
  }
}