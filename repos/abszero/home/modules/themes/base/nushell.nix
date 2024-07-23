{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.nushell;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.base.nushell.enable = mkExternalEnableOption config "base nushell theme";

  config.programs.nushell.extraConfig = mkIf cfg.enable ''
    $env.config = ($env.config? | default {} | merge {
      table: {
        mode: light
        # header_on_separator: true
      }
    });
  '';
}
