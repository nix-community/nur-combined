# Desktop running local AI
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.profiles.desktopWithAI;
in

{
  imports = [ ./desktop.nix ];

  options.abszero.profiles.desktopWithAI.enable = mkEnableOption "AI-enabled desktop profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.desktop.enable = true;
      services = {
        comfyui.enable = true;
        llama-cpp.enable = true;
        sillytavern.enable = true;
      };
      programs.crush.enable = true;
    };

    environment.systemPackages = with pkgs; [
      skills
    ];
  };
}
