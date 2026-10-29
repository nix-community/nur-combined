# @summary Manages SEOWebChecker automated SEO auditing agent and reporting services.
#
# Deploys the technical SEO auditing engine on web nodes, manages scheduled cron/systemd
# health checks, and exports JSON/Markdown audit reports.
#
# @see https://seowebchecker.com/
#
# @param ensure
#   Whether the SEOWebChecker resources should be present or absent.
#
# @param log_dir
#   Directory path for storing audit history and error logs.
#
# @param report_dir
#   Directory path where web-accessible JSON or Markdown reports are stored.
#
# @param default_alert_threshold
#   Default minimum SEO health score (0-100) before triggering an alert (default: 85).
#
# @param sites
#   Hash of `seowebchecker::site` resources to configure automatically.
#
# @example Basic usage
#   include seowebchecker
#
# @example Monitoring custom sites
#   class { 'seowebchecker':
#     default_alert_threshold => 90,
#     sites                   => {
#       'production' => {
#         'url'             => 'https://seowebchecker.com/',
#         'alert_threshold' => 90,
#         'cron_schedule'   => 'daily',
#       },
#     },
#   }
#
class seowebchecker (
  Enum['present', 'absent'] $ensure                  = 'present',
  Stdlib::Absolutepath      $log_dir                 = '/var/log/seowebchecker',
  Stdlib::Absolutepath      $report_dir              = '/var/www/html/seo-reports',
  Integer[0, 100]           $default_alert_threshold = 85,
  Hash                      $sites                   = {},
) {
  contain seowebchecker::install
  contain seowebchecker::config

  Class['seowebchecker::install']
  -> Class['seowebchecker::config']

  if $ensure == 'present' {
    $sites.each |String $site_name, Hash $site_params| {
      seowebchecker::site { $site_name:
        * => $site_params,
      }
    }
  }
}
