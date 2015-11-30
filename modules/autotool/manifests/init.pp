###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool ($build_doc = true, $html_dir, $cgi_bin, $enable_highscore,
$sandbox, $install_path, $autolib_path, $autotool_path) {
  include autotool::sources
  include autotool::dependencies
  include autotool::autolib
  include autotool::tool
  include autotool::database

  if ($sandbox == true) {
    exec { "initialize sandbox ${install_path}":
      command => 'cabal sandbox init',
      cwd     => $install_path,
      require => Class['autotool::sources'],
      before  => Class['autotool::dependencies'],
    }
  }

  Class['autotool::sources']
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
