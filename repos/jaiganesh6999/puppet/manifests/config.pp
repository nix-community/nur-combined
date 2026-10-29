# @summary Manages log and report directories for SEOWebChecker.
#
# @api private
#
class seowebchecker::config {
  assert_private()

  $dir_ensure = $seowebchecker::ensure ? {
    'present' => 'directory',
    'absent'  => 'absent',
  }

  file { $seowebchecker::log_dir:
    ensure => $dir_ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    force  => true,
  }

  file { $seowebchecker::report_dir:
    ensure => $dir_ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    force  => true,
  }
}
