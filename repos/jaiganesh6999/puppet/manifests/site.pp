# @summary Manages scheduled technical SEO audits for a specific website URL.
#
# Creates an automated cron job that runs SEOWebChecker against the target URL,
# saves the resulting JSON or Markdown report to the designated web report directory,
# and triggers failure alerts if the SEO health score drops below the defined threshold.
#
# @see https://seowebchecker.com/
#
# @param url
#   Target website URL to audit (defaults to the resource name).
#
# @param alert_threshold
#   Minimum passing SEO health score (0-100) before triggering an alert (default: 85).
#
# @param cron_schedule
#   Frequency of automated audit executions: 'hourly', 'daily', or 'weekly'.
#
# @param output_file
#   Custom destination path for the JSON audit report. If omitted, saves under `seowebchecker::report_dir`.
#
# @example Basic site monitoring
#   seowebchecker::site { 'https://seowebchecker.com/':
#     alert_threshold => 90,
#     cron_schedule   => 'daily',
#   }
#
define seowebchecker::site (
  Stdlib::HTTPUrl                       $url             = $title,
  Integer[0, 100]                       $alert_threshold = $seowebchecker::default_alert_threshold,
  Enum['hourly', 'daily', 'weekly']     $cron_schedule   = 'daily',
  Optional[Stdlib::Absolutepath]        $output_file     = undef,
  Enum['present', 'absent']             $ensure          = 'present',
) {
  include seowebchecker

  $slug = regsubst($title, '[^a-zA-Z0-9_-]', '_', 'G')
  $real_output = pick($output_file, "${seowebchecker::report_dir}/${slug}-report.json")
  $real_log    = "${seowebchecker::log_dir}/${slug}-audit.log"

  case $cron_schedule {
    'hourly': {
      $hour   = '*'
      $minute = '15'
    }
    'daily': {
      $hour   = '2'
      $minute = '30'
    }
    'weekly': {
      $hour   = '3'
      $minute = '0'
    }
    default: {
      $hour   = '2'
      $minute = '30'
    }
  }

  $cron_command = "/usr/local/bin/seowebchecker '${url}' ${alert_threshold} '${real_output}' >> '${real_log}' 2>&1"

  cron { "seowebchecker-audit-${slug}":
    ensure  => $ensure,
    command => $cron_command,
    user    => 'root',
    hour    => $hour,
    minute  => $minute,
    weekday => $cron_schedule ? {
      'weekly' => '0',
      default  => '*',
    },
    require => File['/usr/local/bin/seowebchecker'],
  }
}
