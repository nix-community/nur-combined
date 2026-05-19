{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (builtins) fromJSON readFile;
  cfg = config.abszero.themes.base.fastfetch;
in

{
  options.abszero.themes.base.fastfetch.enable = mkEnableOption "base fastfetch theme";

  config.programs.fastfetch.settings = mkIf cfg.enable (fromJSON (readFile ./config.json));
}
