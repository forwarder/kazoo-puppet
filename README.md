# Kazoo 3.0 module for Puppet

This is still work in progress, but you should be able to deploy a cluster with this setup.

Feel free to fork and send pull requests for any improvements.

## Basic node configuration


    node kazoonode inherits common {
    
      $cookie = 'change_me'

      $rabbitmq_ip = '192.168.0.1'

      $freeswitch_nodes = {
        'fs01' => {
          'ip' => '192.168.0.2',
          'hostname' => 'fs01.yourhostname.com'
        },
        'fs02' => {
          'ip' => '192.168.0.3',
          'hostname' => 'fs02.yourhostname.com'
        }
      }
      
      $bigcouch_nodes = {
        'db01' => {
          'ip' => '192.168.0.4',
          'hostname' => 'db01.yourhostname.com'
        },
        'db02' => {
          'ip' => '192.168.0.5',
          'hostname' => 'db02.yourhostname.com'
        }
      }
    
    }

    node 'kazoo.yourhostname.com' inherits kazoonode {
  
      class { 'kazoo::whapps':
        cookie => $cookie,
        rabbitmq_ip => '127.0.0.1',
        bigcouch_nodes => $bigcouch_nodes,
        freeswitch_nodes => $freeswitch_nodes
      }
  
      class { 'kazoo::ui': }
  
    }

    node 'fs01.yourhostname.com' inherits kazoonode {
  
      class { 'kazoo::freeswitch':
        cookie => $cookie,
        rabbitmq_ip => $rabbitmq_ip,
        bigcouch_nodes => $bigcouch_nodes
      }
  
    }
    
    node 'fs02.yourhostname.com' inherits kazoonode {
  
      class { 'kazoo::freeswitch':
        cookie => $cookie,
        rabbitmq_ip => $rabbitmq_ip,
        bigcouch_nodes => $bigcouch_nodes
      }
  
    }

    node 'db01.yourhostname.com' inherits kazoonode {
  
      class { 'kazoo::bigcouch':
        cookie => $cookie,
        is_primary => true,
        bigcouch_nodes => $bigcouch_nodes
      }
  
    }
    
    node 'db02.yourhostname.com' inherits kazoonode {
  
      class { 'kazoo::bigcouch':
        cookie => $cookie,
        bigcouch_nodes => $bigcouch_nodes
      }
  
    }
    
## Post deployment

Follow the post installation instructions provided by 2600hz:
https://2600hz.atlassian.net/wiki/display/Dedicated/via+RPM#viaRPM-PostInstallation

## Todo

* Improve configuration
* Improve rabbitmq implementation
* Test
