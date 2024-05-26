{ config, pkgs, ... }:

let
  inherit (builtins) readFile;
  absCfg = config.abszero.catppuccin;
  cfg = config.catppuccin;

  cssDir =
    pkgs.catppuccin-discord-git.override {
      themes0 =
        if absCfg.useSystemPolarity then
          [
            "${absCfg.lightFlavor}-${cfg.accent}"
            "${absCfg.darkFlavor}-${cfg.accent}"
          ]
        else
          [ "${cfg.flavor}-${cfg.accent}" ];
    }
    + "/share/catppuccin-discord";
in

{
  imports = [ ./catppuccin.nix ];

  programs.discocss.css =
    if absCfg.useSystemPolarity then
      ''
        ${readFile (cssDir + "/catppuccin-${absCfg.lightFlavor}-${cfg.accent}.theme.css")}

        @media (prefers-color-scheme: dark) {
        ${readFile (cssDir + "/catppuccin-${absCfg.darkFlavor}-${cfg.accent}.theme.css")}
        }
      ''
    else
      readFile (cssDir + "/catppuccin-${cfg.flavor}-${cfg.accent}.theme.css");
}
