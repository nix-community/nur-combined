{ config, pkgs, ... }:

let
  inherit (builtins) readFile;
  inherit (config.lib.catppuccin) getVariant;
  cfg = config.abszero.themes.catppuccin;

  cssDir = pkgs.catppuccin-discord-git.override
    {
      themes0 =
        if cfg.automaticThemeSwitching then
          [
            "${cfg.lightVariant}-${cfg.accent}"
            "${cfg.darkVariant}-${cfg.accent}"
          ]
        else
          [ "${getVariant}-${cfg.accent}" ];
    }
  + "/share/catppuccin-discord";
in

{
  imports = [ ./_options.nix ];

  programs.discocss.css =
    if cfg.automaticThemeSwitching then
      ''
        ${readFile (cssDir + "/catppuccin-${cfg.lightVariant}-${cfg.accent}.theme.css")}

        @media (prefers-color-scheme: dark) {
        ${readFile (cssDir + "/catppuccin-${cfg.darkVariant}-${cfg.accent}.theme.css")}
        }
      ''
    else
      readFile (cssDir + "/catppuccin-${getVariant}-${cfg.accent}.theme.css");
}
