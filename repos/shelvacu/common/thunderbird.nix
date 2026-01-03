{
  lib,
  config,
  vacuModuleType,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.vacu.programs.thunderbird = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = lib.optionalAttrs (vacuModuleType == "nixos") (
    lib.mkIf config.vacu.programs.thunderbird.enable {
      programs.thunderbird = {
        enable = true;
        package = pkgs.betterbird;
        policies = {
          DisableTelemetry = true;
          DNSOverHTTPS.Enabled = false;
          ExtensionSettings = {
            #NTFNTF: Notify on This Folder Not That Folder
            "ntfntf@dan-sullivan.co.uk".installation_mode = "normal_installed";
          };
          SSLVersionMin = "tls1.3";
          SearchEngines.Remove = [
            "Amazon.com"
            "Bing"
            "DuckDuckGo"
            "Google"
            "Wikipedia (en)"
          ];
        };
        preferences = {
          # keep-sorted start
          "accessibility.typeaheadfind.flashBar" = 0; # what is this
          "browser.search.region" = "US";
          "calendar.alarms.playsound" = false;
          "calendar.alarms.show" = false;
          "calendar.ui.version" = 3;
          "intl.date_time.pattern_override.date_full" = "MMMM d, yyyy G z";
          "intl.date_time.pattern_override.date_short" = "yyyy-MM-dd";
          "intl.date_time.pattern_override.time_medium" = "HH:mm:ss z";
          "intl.date_time.pattern_override.time_short" = "HH:mm";
          "mail.account.account1.identities" = "id1,id2,id3";
          "mail.account.account1.server" = "server1";
          "mail.compose.other.header" = "X-Shelvacu-Custom-Header";
          "mail.compose.warned_about_customize_from" = true;
          "mail.identity.id1.catchAll" = true;
          "mail.identity.id1.fullName" = "Shelvacu";
          "mail.identity.id1.useremail" = "shelvacu@shelvacu.com";
          "mail.server.server1.hostname" = "imap.shelvacu.com";
          "mail.server.server1.login_at_startup" = true;
          "mail.server.server1.name" = "shelvacu@shelvacu.com";
          "mail.server.server1.port" = 993;
          "mail.server.server1.socketType" = 3; # TLS (as opposed to plaintext or STARTTLS)
          "mail.server.server1.type" = "imap";
          "mail.server.server1.userName" = "shelvacu";
          "mail.shell.checkDefaultClient" = false;
          "mail.showCondensedAddresses" = false;
          "mail.smtp.defaultserver" = "smtp1";
          "mail.smtpserver.smtp1.authMethod" = 3;
          "mail.smtpserver.smtp1.hostname" = "smtp.shelvacu.com";
          "mail.smtpserver.smtp1.port" = 465;
          "mail.smtpserver.smtp1.try_ssl" = 3;
          "mail.smtpserver.smtp1.type" = "smtp";
          "mail.smtpserver.smtp1.username" = "shelvacu";
          "mail.startup.enabledMailCheckOnce" = true;
          "mail.threadpane.listview" = 1;
          # don't warn when sending with ctrl+enter
          "mail.warn_on_send_accel_key" = false;
          "mailnews.customHeaders" = "X-Vacu-Action";
          "mailnews.default_sort_type" = 27;
          "mailnews.mark_message_read.auto" = false;
          "mailnews.start_page.enabled" = false;
          # keep-sorted end
        };
      };
    }
  );
}
