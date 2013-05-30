class supervisor::package(
  $ensure = 'present'
) {
  $version = '3.0b2'
  $supervisor_dir = '/opt/supervisor'
  $flags = '.gz' ? {
    'bz2'   => 'jvxf',
    default => 'zvxf'
  }
  $download_url = "https://pypi.python.org/packages/source/s/supervisor/supervisor-$version.tar.gz"
  
  wget::fetch { 'download_supervisor':
    source      => $download_url,
    destination => "/usr/local/src/supervisor-$version.tar.bz",
    before      => Exec['untar_zookeeper'],
    require     => Class['wget'],
    flags       => '--no-check-certificate',
  }

  exec { 'untar_supervisor':
    command => "tar xzf /usr/local/src/supervisor-$version.tar.bz",
    cwd     => '/opt',
    creates => "${supervisor_dir}-$version",
    path    => ['/bin', '/usr/bin'],
    before  => File[$supervisor_dir],
  }

  file { $supervisor_dir:
    ensure => link,
    target => "${supervisor_dir}-$version"
  }

  file { "${supervisor_dir}-$version":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    recurse => true,
    require => Exec['untar_supervisor'],
  }

  exec { 'install_supervisor':
    command => 'python setup.py install',
    creates => '/usr/bin/supervisorctl',
    cwd     => "$supervisor_dir",
    require => Package['python-setuptools'],
    path    => '/usr/bin',
  }
}