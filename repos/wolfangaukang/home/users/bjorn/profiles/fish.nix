{
  osConfig,
  inputs,
  pkgs,
  ...
}:

let
  terminalSettings = import "${inputs.self}/home/users/bjorn/settings/terminal.nix" { inherit pkgs; };

in
{
  programs.fish = {
    enable = osConfig.programs.fish.enable;
    shellAliases = terminalSettings.shellAliases;
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];
  };
  xdg.configFile =
    let
      base_path = "${inputs.dotfiles}/config/fish";

    in
    {
      "fish/functions/_tide_item_jj.fish".source = "${base_path}/functions/_tide_item_jj.fish";
      "fish/conf.d/tide-prompt-items.fish".source = "${base_path}/conf.d/tide-prompt-items.fish";
    };
}
