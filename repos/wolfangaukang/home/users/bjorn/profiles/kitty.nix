{
  config,
  inputs,
  pkgs,
  ...
}:

let
  terminalSettings = import "${inputs.self}/home/users/bjorn/settings/terminal.nix" { inherit pkgs; };

in
{
  programs.kitty = {
    enable = true;
    font = terminalSettings.font;
    themeFile = "BlackMetal";
    shellIntegration = {
      mode = "no-sudo";
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };
  };
}
