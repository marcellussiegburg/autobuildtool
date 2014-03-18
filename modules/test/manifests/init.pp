###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class test {
  $test1 = 'w3m http://localhost/cgi-bin/Super.cgi -dump -T text/html | grep autotool'
  $test1a = 'w3m http://localhost/cgi-bin/Super.cgi -dump_head | head -1 | grep "404 Not Found"'

  test::testcase { 'Test 1':
    command => $test1,
    success => 'Page is running.',
    failure => 'Page is not running.',
  }

  test::testcase { 'Test 1a':
    command => $test1a,
    success => 'Super.cgi is not available.',
    failure => 'It seems there is different Application running, you may check if autotool is running. - Reviewing "Test 1" might be required.',
    unless  => $test1,
  }
}
