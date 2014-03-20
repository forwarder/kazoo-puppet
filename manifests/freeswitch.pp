class kazoo::freeswitch (
  
  $rabbitmq_ip = '127.0.0.1',
  $bigcouch_nodes = []
  
) {
  
  require kazoo
  
  package { 'kazoo-freeswitch-R15B': ensure => installed, require => File['/etc/yum.repos.d/2600hz.repo'] }
  package { 'haproxy': ensure => installed, require => File['/etc/yum.repos.d/epel.repo'] }
  
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
    command => "rm -rf /etc/haproxy/haproxy.cfg"
  }
  exec { 'symlink-haproxy-cfg': 
    command => "ln -s /etc/kazoo/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg"
  }
  file {'/etc/haproxy/haproxy.conf':
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
    enabled => true,
    require => [
      Package['haproxy'],
      Exec['remove-haproxy-cfg','symlink-haproxy-cfg']
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