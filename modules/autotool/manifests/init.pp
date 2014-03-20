###  (c) Marcellus Siegburg, 2013-2014, License: GPL
class autotool ($build_doc = true){
  include autotool::autolib
  include autotool::tool
  include autotool::database

  Class['autotool']
  -> Class['autotool::autolib']
  -> Class['autotool::tool']
  -> Class['autotool::database']

  if ($autotool::autolib::build_doc == true or
  $autotool::tool::build_doc == true) {
    include autotool::doc
    Class['autotool::tool'] -> Class['autotool::doc']
  }
}
