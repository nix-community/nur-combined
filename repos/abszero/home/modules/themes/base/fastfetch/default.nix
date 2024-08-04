{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (builtins) fromJSON readFile;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.fastfetch;
in

{
  imports = [ ../../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.base.fastfetch.enable = mkExternalEnableOption config "base fastfetch theme";

  config.programs.fastfetch.settings = mkIf cfg.enable (fromJSON (readFile ./config.json));
}
