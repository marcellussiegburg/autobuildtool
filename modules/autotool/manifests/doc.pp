###  (c) Marcellus Siegburg, 2013, License: GPL
class autotool::doc {
  case $::operatingsystem {
    ubuntu: {
      $html_dir = '/var/www'
    }
    CentOS: {
      $html_dir = '/var/www/html'
    }
  }
  $domain = 'http://localhost'
  $port = '80'
  $doc_path = 'ghc-doc'
  $source_user = "/home/vagrant/.cabal/share/doc"
  $target_user = "${html_dir}/${doc_path}"
  $source_system = "/usr/local/share/doc/ghc/html"
  $target_system = "${html_dir}/${doc_path}/html"
  
  # Replace / with \/ to work with sed's regexps
  $source_user_sed = regsubst("${source_user}/", '/', '\\/', 'G')
  $target_user_sed = regsubst("${domain}:${port}/${doc_path}/", '/', '\\/', 'G')
  $source_system_sed = regsubst("${source_system}", '/', '\\/', 'G')
  $target_system_sed = regsubst("${domain}:${port}/${doc_path}/html/", '/', '\\/', 'G')
  
  # Replace only necessary on $target_user because $target_system is a subdir of it
  $replace_user = "find ${target_user} -type f -exec sed -i \"s/\\\"${source_user_sed}/\\\"${target_user_sed}/g\" {} \\;"
  $replace_system = "find ${target_user} -type f -exec sed -i \"s/\\\"${source_system_sed}/\\\"${target_system_sed}/g\" {} \\;"

  $rsync = 'rsync -qruklEt'
  $rsync_user = "${rsync} --exclude=${target_system} ${source_user}/ ${target_user}"
  $rsync_system = "${rsync} ${source_system}/ ${target_system}"

  file {
    [$target_user, $target_system]:
      ensure => directory,
  }

  exec {
    [$rsync_user, $rsync_system]:
      user    => 'root',
      require =>
        [ File[$target_user],
          File[$target_system] ];
    [$replace_user, $replace_system]:
      user        => 'root',
      refreshonly => true,
      subscribe   =>
        [ Exec[$rsync_user],
          Exec[$rsync_system] ];
  }
}