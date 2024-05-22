{ config, pkgs, ... }:

let
  inherit (builtins) readFile;
  absCfg = config.abszero.catppuccin;
  cfg = config.catppuccin;

  cssDir = pkgs.catppuccin-discord-git.override
    {
      themes0 =
        if absCfg.useSystemPolarity then
          [
            "${absCfg.lightFlavour}-${cfg.accent}"
            "${absCfg.darkFlavour}-${cfg.accent}"
          ]
        else
          [ "${cfg.flavour}-${cfg.accent}" ];
    }
  + "/share/catppuccin-discord";
in

{
  imports = [ ./catppuccin.nix ];

  programs.discocss.css =
    if absCfg.useSystemPolarity then
      ''
        ${readFile (cssDir + "/catppuccin-${absCfg.lightFlavour}-${cfg.accent}.theme.css")}

        @media (prefers-color-scheme: dark) {
        ${readFile (cssDir + "/catppuccin-${absCfg.darkFlavour}-${cfg.accent}.theme.css")}
        }
      ''
    else
      readFile (cssDir + "/catppuccin-${cfg.flavour}-${cfg.accent}.theme.css");
}
