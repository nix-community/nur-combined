{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (builtins) fromJSON readFile;
  cfg = config.abszero.programs.opencode;
in

{
  options.abszero.programs.opencode.enable = mkEnableOption "open AI agent";

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      cli = fromJSON (readFile ./cli.json);
      settings = fromJSON (readFile ./opencode.json);
    };
  };
}
