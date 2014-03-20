class kazoo::bigcouch (
  
  $cookie = 'change_me',
  $rabbitmq_ip = '127.0.0.1',
  $is_primary = false,
  $bigcouch_nodes = []
  
) {
  
  require kazoo
  
  package { 'kazoo-bigcouch-R15B': ensure => installed, require => File['/etc/yum.repos.d/2600hz.repo'] }

  if $is_primary == true {
    each($bigcouch_nodes) |$node| {
      unless $node['hostname'] == $fqdn {
        exec { 'add-node':
          command: "curl -X PUT ${fqdn}:5986/nodes/bigcouch@${node.hostname} -d {}",
          require: Service['bigcouch']
        }
      }
    }
  }
  
  service { 'bigcouch':
    ensure => running,
    enable => true,
    require => Package['kazoo-bigcouch-R15B']
  }

}