###  (c) Marcellus Siegburg, 2014, License: GPL
class autotool::sources ($autolib_url, $autolib_branch, $tool_url,
$tool_branch, $disable = false) {
  $lib_path = $::autotool::autolib_path
  $lib_url = $autolib_url
  $lib_branch = $autolib_branch

  if ($disable == false) {
    exec { 'git clone autolib':
      command => "git clone ${lib_url} ${lib_path}",
      unless  => "test -d ${lib_path}",
    }

    exec { 'git fetch autolib':
      command => 'git fetch',
      cwd     => $lib_path,
      require => Exec['git clone autolib'],
    }

    exec { 'git checkout autolib':
      command => "git branch -f ${lib_branch} ${lib_branch}; git checkout ${lib_branch}",
      cwd     => $lib_path,
      require => Exec['git fetch autolib'],
      onlyif  => "test -d ${lib_path}",
    }

    exec { 'git merge autolib':
      command => "git merge --ff remotes/origin/${lib_branch} || git merge --ff ${lib_branch}",
      cwd     => $lib_path,
      require => Exec['git checkout autolib'],
      onlyif  => "test -d ${lib_path}",
    }

    $tool_path = $::autotool::autotool_path
    exec { 'git clone tool':
      command => "git clone ${tool_url} ${tool_path}",
      unless  => "test -d ${tool_path}",
    }

    exec { 'git fetch tool':
      command => 'git fetch',
      cwd     => $tool_path,
      require => Exec['git clone tool'],
      onlyif  => "test -d ${tool_path}",
    }

    exec { 'git checkout tool':
      command => "git branch -f ${tool_branch} ${tool_branch}; git checkout ${tool_branch}",
      cwd     => $tool_path,
      require => Exec['git fetch tool'],
      onlyif  => "test -d ${tool_path}",
    }

    exec { 'git merge tool':
      command => "git merge --ff remotes/origin/${tool_branch} || git merge --ff ${tool_branch}",
      cwd     => $tool_path,
      require => Exec['git checkout tool'],
      onlyif  => "test -d ${tool_path}",
    }
  }
}
