class kazoo {

  file { '/etc/yum.repos.d/2600hz.repo': ensure => 'present', source => 'puppet:///modules/kazoo/2600hz.repo' }

  file { '/selinux/enforce': ensure => 'absent' }
  
  exec { 'yum-clean-all':
    user => 'root',
    path => '/usr/bin',
    command => 'yum clean all',
  }

  Package { require => Exec['yum-clean-all'] }
  
}