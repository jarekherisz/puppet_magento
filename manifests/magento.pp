define magento::magento (
  $tcp_port               = "80",
  $vhost_aliases          = '',
  $vhost                  = $name,
  $php_pool               = "unix:/var/run/php5-fpm-${name}.sock",
  $different_backend_pool = false,
  $backend_php_pool       = "unix:/var/run/php5-fpm-${name}.backend.sock",
  $username               = $nginx::params::username,
  $chmod_path             = "2775",
  $usergroup              = $username,
  $path                   = "${nginx::params::document_root}/${name}",
  $document_root          = $path,
  $https                  = $nginx::params::https,
  $https_tcp_port         = '443',
  $set_real_ip_from       = "127.0.0.1",
  $http_to_https          = false,
  $header_params           = [],
  $ssl_certificate        = "somecert.crt",
  $ssl_certificate_key    = "somecert.key",
  $authentication         = [],
  $locations              = {},
  $locations_d            = {
    "thumbs"             => {
      "location"    => "~ /\.thumbs",
      "description" => [
        "Don't skip .thumbs, this is a default directory where Magento places thumbnails",
        "Nginx cannot not match something, instead the target is matched with an empty block",
        "http://stackoverflow.com/a/16304073"
      ],
      "vhost"       => "${name}",
      "order"       => "005",
      "params"      => {}
    },
    'app'                => {
      'location' => '^~ /app/',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'includes'           => {
      'location' => '^~ /includes/',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'lib'                => {
      'location' => '^~ /lib',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'media_downloadable' => {
      'location' => '^~ /media/downloadable/',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'pkginfo'            => {
      'location' => '^~ /pkginfo/',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'var'                => {
      'location' => '^~ /var/',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'shell'              => {
      'location' => '^~ /shell/',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'downloadable'       => {
      'location' => '^~ /downloadable/',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => { 'return' => '404' }
    },
    'static image'       => {
      'location' => ' ~ ^/.+\.(ico|png|jpe?g|gif|svg|ttf|mp4|mov|swf|pdf|zip|rar|JPG)$',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => {
        'expires'                  => '4838400',
        'add_header Cache-Control' => '"public, no-transform"'
      }
    },
    'static code'        => {
      'location' => ' ~ ^/.+\.(css|js)$',
      "vhost"    => "${name}",
      "order"    => "010",
      "params"   => {
        'expires'                  => '4838400',
        'add_header Cache-Control' => '"private"'
      }
    }
  },
) {

  if($different_backend_pool == false)
  {
    $locations_tmp = $locations_d
  } else
  {
    $locations_tmp = deep_merge($locations_d,
      {
        '/admin' =>
        {
          'location' => '~ ^/(index\.php/admin|admin)/',
          "vhost"    => "${name}",
          "order"    => "011",
          "params"   =>
          {
            "add_header X-Server"           => '$hostname',
            'fastcgi_pass'                  => $backend_php_pool,
            'fastcgi_param SCRIPT_FILENAME' => '$document_root/index.php',
            'fastcgi_param SCRIPT_NAME'     => '$fastcgi_script_name',
            'include'                       => 'fastcgi_params',
            'fastcgi_read_timeout'          => '1200'
          }
        },
      }
    )
  }

  ##Łączy dwie tabele
  $merge_locations = deep_merge($locations_tmp, $locations)

  nginx::vhost2 { $name:
    tcp_port             => $tcp_port,
    vhost_aliases        => $vhost_aliases,
    fastcgi_read_timeout => 3600,
    vhost                => $vhost,
    php_pool             => $php_pool,
    username             => $username,
    usergroup            => $usergroup,
    path                 => $path,
    document_root        => $document_root,
    set_real_ip_from     => $set_real_ip_from,
    https                => $https,
    ssl_certificate      => $ssl_certificate,
    ssl_certificate_key  => $ssl_certificate_key,
    authentication       => $authentication,
    locations            => $merge_locations,
    chmod_path           => $chmod_path,
    header_params        => $header_params
  }

}
