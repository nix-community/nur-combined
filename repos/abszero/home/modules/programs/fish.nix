{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.fish;
in

{
  options.abszero.programs.fish.enable = mkEnableOption "managing fish";

  config.programs = mkIf cfg.enable {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting ""
      '';
      functions = {
        qcomm = "qfile (which $argv)";
        fetchhash = "nix flake prefetch --json $argv | jq -r .hash";
      };
    };

    foot.settings.main.shell = "fish";
    ghostty.settings.command = "fish";
    nix-your-shell.enable = true;
  };
}
