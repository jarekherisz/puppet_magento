# puppet_magento
### Extends module puppet_nginx, to simple generate configurations vhost in nginx for magento.

You can use it instead vhost2 from https://github.com/jarekherisz/puppet_nginix.

To create simple magento vhoste


### A virtual host with alias name
```puppet
class { 'nginx': }

magento::magento  { "domain.com": 
    vhost_aliases => 'www.domain.com www2.domain.com',
}
```
