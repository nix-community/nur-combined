{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.base.nushell;
in

{
  options.abszero.themes.base.nushell.enable = mkEnableOption "base nushell theme";

  config.programs.nushell.extraConfig = mkIf cfg.enable ''
    $env.config = ($env.config? | default {} | merge {
      table: {
        mode: light
        # header_on_separator: true
      }
    });
  '';
}
