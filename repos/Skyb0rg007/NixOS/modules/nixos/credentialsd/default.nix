{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.credentialsd;

  nativeMessagingHostName = "xyz.iinuwa.credentialsd_helper";
  nativeMessagingHostFile = "${nativeMessagingHostName}.json";
  chromiumNativeMessagingHost = pkgs.writeText "credentialsd-chromium-native-messaging-host.json" (
    builtins.toJSON {
      name = nativeMessagingHostName;
      description = "Helper for integrating browsers with credentialsd";
      path = "${cfg.package}/bin/credentialsd-firefox-helper";
      type = "stdio";
      allowed_origins = cfg.browserIntegration.chrome.allowedOrigins;
    }
  );
in
{
  options.services.credentialsd = {
    enable = lib.mkEnableOption "credentialsd";

    package = lib.mkPackageOption pkgs "credentialsd" { };

    browserIntegration = {
      firefox.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to configure the Firefox native messaging host.";
      };

      chrome = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to configure Chrome and Chromium native messaging hosts.";
        };

        allowedOrigins = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "chrome-extension://abcdefghijklmnopabcdefghijklmnop/" ];
          description = ''
            Chrome extension origins allowed to use the credentialsd native
            messaging host.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.dbus.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
    systemd.user.services = {
      "xyz.iinuwa.credentialsd.Credentials".wantedBy = [ "default.target" ];
      "xyz.iinuwa.credentialsd.FlowControl".wantedBy = [ "default.target" ];
      "xyz.iinuwa.credentialsd.UiControl".wantedBy = [ "default.target" ];
    };

    programs.firefox.nativeMessagingHosts.packages = lib.mkIf cfg.browserIntegration.firefox.enable [
      cfg.package
    ];

    environment.etc =
      lib.mkIf
        (cfg.browserIntegration.chrome.enable && cfg.browserIntegration.chrome.allowedOrigins != [ ])
        {
          "chromium/native-messaging-hosts/${nativeMessagingHostFile}".source = chromiumNativeMessagingHost;
          "opt/chrome/native-messaging-hosts/${nativeMessagingHostFile}".source = chromiumNativeMessagingHost;
        };

    warnings =
      lib.optional
        (cfg.browserIntegration.chrome.enable && cfg.browserIntegration.chrome.allowedOrigins == [ ])
        ''
          services.credentialsd.browserIntegration.chrome.enable is true, but
          services.credentialsd.browserIntegration.chrome.allowedOrigins is empty.
          Chrome and Chromium require explicit extension origins for native messaging.
        '';
  };
}
