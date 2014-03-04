###  (c) Marcellus Siegburg, 2013, License: GPL
class test {
  $test1 = 'w3m http://localhost/cgi-bin/Super.cgi -dump -T text/html | grep autotool'
  $test1a = 'w3m http://localhost/cgi-bin/Super.cgi -dump -T text/html | grep "Not Found"'

  test::testcase { 'Test 1':
    command => $test1,
    success => 'Page is running.',
    failure => 'Page is not running.',
  }

  test::testcase { 'Test 1a':
    command => $test1a,
    success => 'Super.cgi is not available.',
    failure => 'Page is not running. Maybe it changed? - Reviewing this test case might be required.',
    unless  => $test1,
  }
}
