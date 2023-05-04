# docs: <nixpkgs:nixos/modules/services/networking/yggdrasil.md>
# - or message CW/0x00

{ config, lib, ... }:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.sane.yggdrasil;
in
{
  options.sane.yggdrasil = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
    services.yggdrasil = {
      enable = true;
      persistentKeys = true;
      config = {
        IFName = "ygg0";
        Peers = [
          "tls://longseason.1200bps.xyz:13122"
        ];
      };
    };
  };
}

