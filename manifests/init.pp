class supervisor(
  $ensure                   = 'present',
  $package                  = 'python-supervisor',
  $autoupgrade              = false,
  $service_ensure           = 'running',
  $service_enable           = true,
  $enable_inet_server       = false,
  $inet_server_port         = '*:9000',
  $inet_server_user         = undef,
  $inet_server_pass         = undef,
  $enable_logrotate         = true,
  $logfile                  = '/var/log/supervisor/supervisord.log',
  $logfile_maxbytes         = '500MB',
  $logfile_backups          = 10,
  $log_level                = 'info',
  $minfds                   = 1024,
  $minprocs                 = 200,
  $childlogdir              = '/var/log/supervisor',
  $nocleanup                = false,
  $user                     = undef,
  $umask                    = '022',
  $supervisor_environment   = undef,
  $identifier               = undef,
  $recurse_config_dir       = false,
  $conf_ext                 = '.ini',
  $include_files            = []
) {
  # consider moving to RIP's data module

  $conf_file = $::osfamily ? {
    'Debian' => '/etc/supervisor/supervisord.conf',
    default  => '/etc/supervisord.conf' # RedHat
  }

  $conf_dir = $::osfamily ? {
    'Debian' => '/etc/supervisor',
    default  => '/etc/supervisord.d'
  }

  $system_service = $::osfamily ? {
    'Debian' => 'supervisor',
    default  => 'supervisord' # RedHat
  }

  # handling status of package/service

  case $ensure {
    present: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }

      case $service_ensure {
        running, stopped: {
          $service_ensure_real = $service_ensure
        }
        default: {
          fail('service_ensure parameter must be running or stopped')
        }
      }

      $dir_ensure = 'directory'
      $file_ensure = 'file'
    }
    absent: {
      $package_ensure = 'absent'
      $service_ensure_real = 'stopped'
      $dir_ensure = 'absent'
      $file_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure  => $package_ensure,
  }

  class { 'supervisor::config':
    content => template('supervisor/supervisord.conf.erb'),
    notify  => Service[$system_service],
    require => Package[$package],
  }

  Service[$system_service] -> Supervisor::Service <| |>

  service { $system_service:
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasrestart => true,
    require    => [
      File[$conf_file],
      Class['supervisor::config']
    ],
  }

  # this update call is made from all supervisor::service
  # defines, so there's no need to order/require anything
  # from it inside this class.

  exec { 'supervisor::update':
    command     => '/usr/bin/supervisorctl update',
    logoutput   => on_failure,
    refreshonly => true,
  }

  if $enable_logrotate {
    file { '/etc/logrotate.d/supervisor':
      ensure  => $file_ensure,
      source  => 'puppet:///modules/supervisor/logrotate',
    }
  }
}