define magento::cleanup (
  $document_root = $nginx::params::document_root,
  $session_dir = "var/session",
  $report_dir = "var/report",
  $cache_dir = "var/cache",
  $log_dir = "var/log",
  $catalog_media_cache_dir = "media/catalog/product/cache",
  $shell_dir = "shell",
  $session = true,
  $report = true,
  $cache = true,
  $log = true,
  $catalog_media_cache = false,
  $mysql = true,
)

{
  #czysci folder z sesjami
  #tidy { "${document_root}/${name}/${session_dir}":
  #  age     => '5d',
  #  recurse => true,
  #  rmdirs  => false,
  #  type    => mtime,
  #}

  #czysci folder z raportami błedów
  #tidy { "${document_root}/${name}/${report_dir}":
  #  age     => '5d',
  #  recurse => true,
  #  rmdirs  => false,
  #  type    => mtime,
  #}


  ##tworzy skrypt dodany do clona który bedzie czyscil cache baze itp
  file { "${nginx::params::document_root}/${name}/${shell_dir}/cleanup.sh":
    ensure => present,
    content => template ("${module_name}/cleanup.sh.erb"),
    owner  => "root",
    group  => "root",
    mode   => "700",
  }



  cron { "magento_cleanup_${name}":
    command => "${nginx::params::document_root}/${name}/${shell_dir}/cleanup.sh",
    user    => root,
    require => File["${nginx::params::document_root}/${name}/${shell_dir}/cleanup.sh"],
    hour    => 22,
    minute  => 0
  }

  ##TODO
  ##tworzy skrypt który wyswietla nieuzywane obrazy
  ##wersja testowa potwierdzic dzialanie i dodac kasowanie
  file { "${nginx::params::document_root}/${name}/${shell_dir}/cleanup_images.php":
    ensure => present,
    content => template ("${module_name}/cleanup_images.php.erb"),
    owner  => "root",
    group  => "root",
    mode   => "700",
  }

}