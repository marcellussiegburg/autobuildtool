class test {  
  exec { 'Test 1 passed: Page is running':
    command => "echo 'Test 1 passed'",
    onlyif => "w3m http://localhost/cgi-bin/Super.cgi -dump -T text/html | grep autotool",
    require => Class["apache"],
  }

  exec { 'Test 1 failed: Super.cgi is not available':
    command => "echo 'Test 1 failed'",
    onlyif => "w3m http://localhost/cgi-bin/Super2.cgi -dump -T text/html | grep 'Not Found'",
    require => Class["apache"],
  }
}
