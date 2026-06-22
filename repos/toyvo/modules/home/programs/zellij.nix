{
  config,
  lib,
  inputs,
  system,
  ...
}:
let
  cfg = config.programs.zellij;
in
{
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      settings = {
        theme = "catppuccin-${config.catppuccin.flavor}";
      };
      enableFishIntegration = lib.mkForce false;
      enableBashIntegration = lib.mkForce false;
      enableZshIntegration = lib.mkForce false;
    };
    home.packages = [ inputs.nixcfg.packages.${system}.zellij-wrappers ];
  };
}
