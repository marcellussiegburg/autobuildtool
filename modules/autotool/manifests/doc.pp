###  (c) Marcellus Siegburg, 2013, License: GPL
class autotool::doc ($relative_links = true, $domain = 'http://localhost', $port = '80', $disable = false) {
  $html_dir = $::autotool::html_dir
  $abs_to_rel = '/vagrant/modules/autotool/files/abs2rel.sh'
  if $relative_links {
    $webroot = $html_dir
  }  else {
    $webroot = "${domain}:${port}"
  }
  $doc_path = 'ghc-doc'
  $hardwaremodel = inline_template("<%= %x{uname -i | tr -d '\n'} %>")
  $folder = "${hardwaremodel}-linux-ghc-${::haskell::ghc::version}"
  $source_user = "${::autotool::install_path}/.cabal-sandbox/share/doc/${folder}"
  $target_user = "${html_dir}/${doc_path}"
  $source_system = '/usr/local/share/doc/ghc/html'
  $target_system = "${html_dir}/${doc_path}/html"

  # Replace / with \/ to work with sed's regexps
  $source_user_sed = regsubst("${source_user}/", '/', '\\/', 'G')
  $target_user_sed = regsubst("${webroot}/${doc_path}/", '/', '\\/', 'G')
  $source_system_sed = regsubst("${source_system}/", '/', '\\/', 'G')
  $target_system_sed = regsubst("${webroot}/${doc_path}/html/", '/', '\\/', 'G')

  # Replace only necessary on $target_user because $target_system is a subdir of it
  $replace_user = "find \"${target_user}\" -type f -exec sed -i \"s/\\\"${source_user_sed}/\\\"${target_user_sed}/g\" {} \\;"
  $replace_system = "find \"${target_user}\" -type f -exec sed -i \"s/\\\"${source_system_sed}/\\\"${target_system_sed}/g\" {} \\;"

  $rsync = 'rsync -qruklEt'
  $rsync_user = "${rsync} --exclude=\"${target_system}\" \"${source_user}/\" \"${target_user}\""
  $rsync_system = "${rsync} \"${source_system}/\" \"${target_system}\""

  $abs_to_rel_user = "bash \"${abs_to_rel}\" \"${target_user}\""

  if ($disable == false) {
    file {
      [$target_user, $target_system]:
        ensure => directory,
        owner  => $::apache::apache_user,
        group  => $::apache::apache_user,
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
    if $relative_links {
      exec {
        [$abs_to_rel_user]:
          user        => 'root',
          refreshonly => true,
          subscribe   =>
          [ Exec[$replace_user],
            Exec[$replace_system] ];
      }
    }
  }
}
