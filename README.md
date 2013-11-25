# puppet-supervisor

Puppet module for configuring the 'supervisor' daemon control
utility. Currently tested on CentOS.

Requires supervisor to be packaged properly for CentOS, named
'python-supervisor' at my [fpm recipes](https://github.com/haf/fpm-recipes).



### Example usage

```puppet
  include supervisor

  supervisor::service {
    'scribe':
      ensure      => present,
      enable      => true,
      command     => '/usr/bin/scribed -c /etc/scribe/scribe.conf',
      environment => 'HADOOP_HOME=/usr/lib/hadoop,LD_LIBRARY_PATH=/usr/lib/jvm/java-6-sun/jre/lib/amd64/server',
      user        => 'scribe',
      group       => 'scribe',
      require     => [ Package['scribe'], User['scribe'] ];
  }
```
