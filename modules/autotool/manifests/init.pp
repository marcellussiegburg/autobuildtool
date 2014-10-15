###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool ($build_doc = true, $html_dir, $cgi_bin,
$autolib_path = '/home/vagrant/autolib', $autotool_path = '/home/vagrant/tool'){
  include autotool::sources
  include autotool::dependencies
  include autotool::autolib
  include autotool::tool
  include autotool::database

  Class['autotool']
  -> Class['autotool::sources']
  -> Class['autotool::dependencies']
  -> Class['autotool::autolib']
  -> Class['autotool::tool']
  -> Class['autotool::database']

  if ($::autotool::enable_highscore == true) {
    include autotool::highscore
    Class['autotool::tool']
    -> Class['autotool::highscore']
  }

  if ($::autotool::autolib::build_doc == true or
  $::autotool::tool::build_doc == true) {
    include autotool::doc
    Class['autotool::tool'] -> Class['autotool::doc']
  }
}
