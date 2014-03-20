class kazoo::ui {
  
  require kazoo
  
  package { 'httpd': ensure => installed }
  package { 'kazoo-ui': ensure => installed, require => File['/etc/yum.repos.d/2600hz.repo'] }
 
  exec { 'set-api-ip': 
    command => "/bin/sed -i s/'api.2600hz.com'/${ipaddress}/g /var/www/html/kazoo-ui/config/config.js",
    require => Package['kazoo-ui']
  }
  
  exec { 'set-default-document': 
    command => "/bin/sed -i 's#/var/www/html#/var/www/html/kazoo-ui#g' /etc/httpd/conf/httpd.conf",
    unless => "/bin/grep -c 'kazoo-ui' /etc/httpd/conf/httpd.conf",
    require => Package['kazoo-ui'],
    notify => Service['httpd']
  }
  
  service { 'httpd':
    ensure => running,
    enable => true,
    require => Package['httpd']
  }
  
}