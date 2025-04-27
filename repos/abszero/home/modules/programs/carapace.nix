{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.carapace;
in

{
  options.abszero.programs.carapace.enable = mkEnableOption "carapace";

  config = mkIf cfg.enable {
    home.sessionVariables.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
    programs.carapace.enable = true;
  };
}
