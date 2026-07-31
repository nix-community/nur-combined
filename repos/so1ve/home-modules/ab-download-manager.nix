{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.ab-download-manager;
  package =
    if cfg.uiScale == null then
      cfg.package
    else
      cfg.package.override {
        inherit (cfg) uiScale;
      };
in
{
  options.programs.ab-download-manager = {
    enable = lib.mkEnableOption "AB Download Manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/ab-download-manager { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/ab-download-manager { }";
      description = "AB Download Manager package to install.";
    };

    uiScale = lib.mkOption {
      type = lib.types.nullOr lib.types.number;
      default = null;
      example = 2;
      description = ''
        Java UI scale factor. Leave this as null to use automatic scaling.
      '';
    };

    browserIntegration.firefox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Register the native messaging host with Firefox.";
      };

      installExtension = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install the official Firefox extension through Firefox policy.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.uiScale == null || cfg.uiScale > 0;
        message = "programs.ab-download-manager.uiScale must be null or a positive number";
      }
      {
        assertion =
          !cfg.browserIntegration.firefox.installExtension || cfg.browserIntegration.firefox.enable;
        message = ''
          programs.ab-download-manager.browserIntegration.firefox.installExtension
          requires programs.ab-download-manager.browserIntegration.firefox.enable
        '';
      }
    ];

    home.packages = [ package ];

    # Older package wrappers exposed the immutable store path to jpackage, so
    # ABDM persisted a launcher that stopped working after garbage collection.
    home.activation.migrateAbDownloadManagerAutostart = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      autostart_file=${lib.escapeShellArg "${config.xdg.configHome}/autostart/com.abdownloadmanager.desktop"}
      if [[ -f "$autostart_file" ]] \
        && ${pkgs.gnugrep}/bin/grep -Eq \
          '^Exec="?/nix/store/[a-z0-9]+-ab-download-manager-[^"/]+/(opt/ab-download-manager/)?bin/ABDownloadManager"?([[:space:]]|$)' \
          "$autostart_file"
      then
        ${pkgs.gnused}/bin/sed -i \
          '/^Exec=/c\Exec="${config.home.profileDirectory}/bin/ABDownloadManager" --background' \
          "$autostart_file"
      fi
    '';

    programs.firefox = lib.mkIf cfg.browserIntegration.firefox.enable {
      nativeMessagingHosts = [ package ];

      policies.ExtensionSettings = lib.mkIf cfg.browserIntegration.firefox.installExtension {
        "firefox-integration@abdownloadmanager.com" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ab-download-manager/latest.xpi";
          default_area = "navbar";
        };
      };
    };
  };
}
