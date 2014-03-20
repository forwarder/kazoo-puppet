class kazoo {

  file { '/etc/yum.repos.d/epel.repo': ensure => 'present', source => 'puppet:///modules/kazoo/epel.repo' }
  file { '/etc/yum.repos.d/2600hz.repo': ensure => 'present', source => 'puppet:///modules/kazoo/2600hz.repo' }
  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6': ensure => 'present', source => 'puppet:///modules/kazoo/RPM-GPG-KEY-EPEL-6' }
	
  file { '/selinux/enforce': ensure => 'absent' }
  
  exec { 'yum-clean-all':
    user => 'root',
    path => '/usr/bin',
    command => 'yum clean all',
  }

  Package { require => Exec['yum-clean-all'] }
  
}