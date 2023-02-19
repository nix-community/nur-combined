{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.paste;
in {
  options.services.paste = {
    enable = mkEnableOption ''
      Paste, a small temporary redis-based pastebin server.
      '';

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.arteneko.paste;
      defaultText = "pkgs.nur.repos.arteneko.paste";
      description = "The paste package to use";
    };
  };

  config = mkIf cfg.enable {
  };
}
