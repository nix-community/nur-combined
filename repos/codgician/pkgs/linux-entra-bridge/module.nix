package:
{ config, lib, ... }:

let
  cfg = config.services.linux-entra-bridge;
in
{
  options.services.linux-entra-bridge = {
    enable = lib.mkEnableOption "Linux Entra Bridge native messaging host";

    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "The Linux Entra Bridge package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Firefox's NixOS module collects native hosts from this option.
    programs.firefox.nativeMessagingHosts.packages = [ cfg.package ];

    environment.etc =
      lib.genAttrs
        [
          "chromium/native-messaging-hosts/linux_entra_bridge.json"
          "opt/chrome/native-messaging-hosts/linux_entra_bridge.json"
          "brave-browser/native-messaging-hosts/linux_entra_bridge.json"
          "vivaldi/native-messaging-hosts/linux_entra_bridge.json"
        ]
        (path: {
          source = "${cfg.package}/etc/${path}";
        });
  };
}
