class kazoo::freeswitch (
  
  $cookie = 'change_me',
  $rabbitmq_ip = '127.0.0.1',
  $bigcouch_nodes = []
  
) {
  
  require kazoo
  
  package { 'kazoo-freeswitch-R15B': ensure => installed, require => File['/etc/yum.repos.d/2600hz.repo'] }
  package { 'haproxy': ensure => installed, require => File['/etc/yum.repos.d/2600hz.repo'] }
  
  #configure freeswitch
  file {'/etc/kazoo/freeswitch/autoload_configs/kazoo.conf.xml':
    notify  => Service['freeswitch'],
    ensure  => file,
    require => Package['kazoo-freeswitch-R15B'],
    content => template('kazoo/freeswitch/kazoo.conf.xml.erb')
  }
  
  service { 'epmd':
    ensure => running,
    enable => true,
    require => [ 
      Package['kazoo-freeswitch-R15B']
    ]
  }
  
  #configure haproxy
  exec { 'remove-haproxy-cfg': 
    command => "/bin/rm -rf /etc/haproxy/haproxy.cfg"
  }
  exec { 'symlink-haproxy-cfg': 
    command => "/bin/ln -s /etc/kazoo/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg"
  }
  file {'/etc/haproxy/haproxy.cfg':
    notify  => Service['haproxy'],
    ensure  => file,
    require => [
      Package['haproxy'],
      Exec['remove-haproxy-cfg','symlink-haproxy-cfg']
    ],
    content => template('kazoo/haproxy.cfg.erb')
  }

  #start services
  service { 'haproxy':
    ensure => running,
    enable => true,
    require => [
      Package['haproxy'],
      File['/etc/haproxy/haproxy.cnf']
    ]
  }
  
  service { 'freeswitch':
    ensure => running,
    enable => true,
    require => [ 
      Package['kazoo-freeswitch-R15B']
    ]
  }

}