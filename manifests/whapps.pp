class kazoo::whapps (
  
  $cookie = 'change_me',
  $rabbitmq_ip = '127.0.0.1',
  $bigcouch_nodes = [],
  $freeswitch_nodes = []
  
) {
  
  require kazoo
  
  package { 'kazoo-R15B': ensure => installed, require => File['/etc/yum.repos.d/2600hz.repo'] }
  package { 'kazoo-kamailio': ensure => installed, require => File['/etc/yum.repos.d/2600hz.repo'] }
  package { 'haproxy': ensure => installed, require => File['/etc/yum.repos.d/epel.repo'] }
  package { 'rsyslog': ensure => installed }
  
  #configure kamailio
  exec { 'set-rabbitmq-dialoginfo-ip':
    command => "s/guest:guest@127.0.0.1:5672\/dialoginfo/guest:guest@'${rabbitmq_ip}':5672\/dialoginfo/g' /etc/kazoo/kamailio/local.cfg"
  }
  exec { 'set-rabbitmq-callmgr-ip': 
    command => "sed -i 's/guest:guest@127.0.0.1:5672\/callmgr/guest:guest@'${rabbitmq_ip}':5672\/callmgr/g' /etc/kazoo/kamailio/local.cfg"
  }
  exec { 'set-kamailio-ip': 
    command => "'s/127.0.0.1/'${ipaddress}'/g' /etc/kazoo/kamailio/local.cfg"
  }
  exec { 'set-kamailio-hostname': 
    command => "'s/kamailio.2600hz.com/'${fqdn}'/g' /etc/kazoo/kamailio/local.cfg"
  }
  exec { 'set-kazoo-rabbitmq-ip': 
    command => "sed -i 's|uri = \"amqp://guest:guest@127.0.0.1:5672\"|uri = \"amqp://guest:guest@${rabbitmq_ip}:5672\"|g' /etc/kazoo/config.ini"
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
  
  #configure freeswitch servers
  file {'/etc/kazoo/kamailio/dbtext/dispatcher':
    notify  => Service['kamailio'],
    ensure  => file,
    require => Package['kazoo-kamailio'],
    content => template('kazoo/kamailio/dispatcher.erb')
  }
  
  #configure kazoo
  file {'/etc/kazoo/config.ini':
    notify  => [
      Service['kz_ecallmgr'],
      Service['kz_whistle_apps']
    ],
    ensure  => file,
    require => Package['kazoo-R15B'],
    content => template('kazoo/config.ini.erb')
  }
  
  #setup services
  service { 'rabbitmq-server':
    ensure => running,
    enabled => true,
    require => Package['kazoo-R15B']
  }
 
  service { 'rsyslog':
    ensure => running,
    enabled => true,
    require => Package['rsyslog']
  }
  Service['rsyslog'] {
    restart => true
  }

  service { 'haproxy':
    ensure => running,
    enabled => true,
    require => [
      Package['haproxy'],
      File['/etc/haproxy/haproxy.conf']
    ]
  }
  
  service { 'kz_whistle_apps':
    ensure => running,
    enable => true,
    require => [ 
      Package['kazoo-R15B'],
      Exec ['set-kazoo-rabbitmq-ip']
    ]
  }
  
  service { 'kz_ecallmgr':
    ensure => running,
    enable => true,
    require => [ 
      Package['kazoo-R15B'],
      Exec ['set-kazoo-rabbitmq-ip']
    ]
  }
  
  service { 'kamailio':
    ensure => running,
    enable => true,
    require => [ 
      Package['kazoo-kamailio'],
      Exec ['set-rabbitmq-dialoginfo-ip', 'set-rabbitmq-callmgr-ip', 'set-kamailio-ip', 'set-kamailio-hostname', 'set-kazoo-rabbitmq-ip']
    ]
  }

}