define magento::magento  (
  $tcp_port = "80",
  $vhost_aliases = '',
  $vhost  = $name,
  $php_pool = "unix:/var/run/php5-fpm-${name}.sock",
  $backend_php_pool = undef,
  $username                     = $nginx::params::username,
  $usergroup                     = $username,
  $document_root = "${nginx::params::document_root}/${name}",
  $https                        = $nginx::params::https,
  $https_tcp_port               = '443',
  $http_to_https               = false,
  $ssl_certificate              = "somecert.crt",
  $ssl_certificate_key          = "somecert.key",
  $authentication               = [],
  $locations  = {},
  $locations_d = {
    "thumbs"=> {
      "location" => "/\.thumbs",
      "description" => [
        "Don't skip .thumbs, this is a default directory where Magento places thumbnails",
        "Nginx cannot not match something, instead the target is matched with an empty block",
        "http://stackoverflow.com/a/16304073"
      ],
      "vhost" => "${name}",
      "order" => "10",
      "params" => { }
    },
    'app' => {
      'location' => '^~ /app/',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    'includes' => {
      'location' => '^~ /includes/',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    'lib' => {
      'location' => '^~ /lib',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    'media_downloadable' => {
      'location' => '^~ /media/downloadable/',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    'pkginfo' => {
      'location' => '^~ /pkginfo/',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    'var' => {
      'location' => '^~ /var/',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    'shell' => {
      'location' => '^~ /shell/',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    'downloadable' => {
      'location' => '^~ /downloadable/',
      "vhost"=>"${name}",
      "order" => "010",
      "params" => { 'return' => '404' }
    },
    '/admin' => {
      'location' => '~ /(index\.php/admin|admin)',
      "vhost"=>"${name}",
      "order" => "011",
      "params" => {
        "index" => "/index.php",
        'location ~ \.php$' => [
          'echo_exec @phpfpm'
        ],
      }
    },
  },
) {

  if($backend_php_pool==undef)
  {
    $locations_tmp = $locations_d
  } else
  {
    $locations_tmp = deep_merge($locations_d,     {'/admin' => {
                                                    "params" => {
                                                      "set" => "\$custom_php_pool unix:/var/run/php5-fpm-${name}.admin.sock",
                                                      'location ~ \.php$' => [
                                                        "set \$custom_php_pool unix:/var/run/php5-fpm-${name}.admin.sock",
                                                        'echo_exec @phpfpm'
                                                      ]
                                                    }
                                                    }
    })
  }

##Łączy dwie tabele
  $merge_locations = deep_merge($locations_tmp, $locations)

  nginx::vhost2{ $name:
    tcp_port => $tcp_port,
    vhost_aliases =>$vhost_aliases,
    fastcgi_read_timeout => 3600,
    vhost => $vhost,
    php_pool => $php_pool,
    username => $username,
    usergroup => $usergroup,
    document_root => $document_root,
    https => $https,
    ssl_certificate => $ssl_certificate,
    ssl_certificate_key => $ssl_certificate_key,
    authentication  =>   $authentication,
    locations => $merge_locations
  }

}
