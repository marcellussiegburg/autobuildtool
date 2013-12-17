###  (c) Marcellus Siegburg, 2013, License: GPL
class test {
  $test1 = "w3m http://localhost/cgi-bin/Super.cgi -dump -T text/html | grep autotool"
  $test1a = "w3m http://localhost/cgi-bin/Super.cgi -dump -T text/html | grep 'Not Found'"

  define testcase($command, $success = "", $failure = "", $unless = undef) {
    exec { "${title} pass: ${success}":
      command => "echo '${title} pass: ${success}'",
      onlyif => "${command}",
      logoutput => true,
    }
    exec { "${title} fail: ${failure}":
      command => "echo '${title} pass: ${failure}'",
      onlyif => "bash -c 't=\"bash -c ${command}\"; test $? -ne 0'",
      logoutput => true,
    }
  }
    
  testcase { "Test 1":
    command => $test1,
    success => "Page is running.",
    failure => "Page is not running.",
  }
  
  testcase { "Test 1a":
    command => $test1a,
    success => "Super.cgi is not available.",
    failure => "Page is not running. Maybe it changed? - Reviewing this test case might be required.",
    unless => $test1,
  }
}
