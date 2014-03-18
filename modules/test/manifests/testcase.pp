###  (c) Marcellus Siegburg, 2013, License: GPL
define test::testcase($command, $success = '', $failure = '', $unless = []) {
  exec { "${title} pass: ${success}":
    command   => "echo '${title} pass: ${success}'",
    onlyif    => $command,
    logoutput => true,
    unless    => $unless,
  }

  exec { "${title} fail: ${failure}":
    command   => "echo '${title} pass: ${failure}'",
    onlyif    => "bash -c 't=\"bash -c ${command}\"; test $? -ne 0'",
    logoutput => true,
    unless    => $unless,
  }
}
