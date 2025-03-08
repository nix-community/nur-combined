{ osConfig
, inputs
, pkgs
, ...
}:

let
  terminalSettings = import "${inputs.self}/home/users/bjorn/settings/terminal.nix" { inherit pkgs; };

in {
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
}

