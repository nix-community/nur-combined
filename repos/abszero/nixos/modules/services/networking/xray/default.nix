{ config, pkgs, lib, ... }:

let
  inherit (lib) types mkOption mkEnableOption mkIf;
  cfg = config.abszero.services.xray;

  presets = [
    "vless-tcp-xtls-reality-server"
    "vless-tcp-xtls-reality-client"
    "blackhole-adblock"
  ];
in

{
  imports = map (s: ./${s}.nix) presets;

  options.abszero.services.xray = {
    enable = mkEnableOption "anti-censorship platform";
    preset = mkOption {
      type = types.enum presets;
      description = "The config preset to use";
    };
    address = mkOption {
      type = types.nonEmptyStr;
      default = "0.0.0.0";
      description = "Server address (client only)";
    };
    clientIds = mkOption {
      type = with types; listOf nonEmptyStr;
      description = "List of client IDs (server only)";
    };
    clientId = mkOption {
      type = types.nonEmptyStr;
      default = builtins.head config.abszero.users.admins;
      description = "Client ID (client only)";
    };
    reality = {
      privateKey = mkOption {
        type = types.nonEmptyStr;
        description = "Generate with `xray x25519` (server only)";
      };
      publicKey = mkOption {
        type = types.nonEmptyStr;
        description = "Generate with `xray x25519` (client only)";
      };
      shortIds = mkOption {
        type = with types; listOf str;
        default = [ "" ];
        description = ''
          List of shortIds that can be used by clients. By default, shortId can
          be empty. Generate with `openssl rand -hex 8`. (server only)
        '';
      };
      shortId = mkOption {
        type = types.str;
        default = "";
        description = "Generate with `openssl rand -hex 8` (client only)";
      };
    };
  };

  config.services.xray = mkIf cfg.enable {
    enable = true;
    package = with pkgs; xray.override {
      assets = [ v2ray-rules-dat.geoip v2ray-rules-dat.geosite ];
    };
  };
}
