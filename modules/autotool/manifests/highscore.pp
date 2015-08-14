###  (c) Marcellus Siegburg, 2014, License: GPL
class autotool::highscore {
  $scorer = '/home/vagrant/.cabal/bin/autotool-Scorer'
  $logs = '/space/autotool/log/*/*/*/CGI'
  $html_dir = $::autotool::html_dir
  $scores = "${html_dir}/high/score.html"

  file {
    "${html_dir}/high":
      ensure => directory,
      owner  => $::apache::apache_user,
      group  => $::apache::apache_user;
    ['/space', '/space/autotool']:
      ensure => directory,
      owner  => $::apache::apache_user,
      group  => $::apache::apache_user;
  }

  cron { 'autotool_highscore':
    command => "${scorer} ${logs} 2> /dev/null 1> /tmp/score.html && mv /tmp/score.html ${scores}",
    user    => $::apache::apache_user,
    minute  => '*/5'
  }
}
