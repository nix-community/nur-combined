{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (builtins) readFile;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  cssDir =
    pkgs.catppuccin-discord_git.override {
      themes0 =
        if cfg.useSystemPolarity then
          [
            "${cfg.lightFlavor}-${ctpCfg.accent}"
            "${cfg.darkFlavor}-${ctpCfg.accent}"
          ]
        else
          [ "${ctpCfg.flavor}-${ctpCfg.accent}" ];
    }
    + "/share/catppuccin-discord";
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.discord.enable =
    mkExternalEnableOption config "catppuccin discord theme";

  config = mkIf cfg.discord.enable {
    abszero.themes.catppuccin.enable = true;
    programs.discocss.css =
      if cfg.useSystemPolarity then
        ''
          ${readFile (cssDir + "/catppuccin-${cfg.lightFlavor}-${ctpCfg.accent}.theme.css")}

          @media (prefers-color-scheme: dark) {
          ${readFile (cssDir + "/catppuccin-${cfg.darkFlavor}-${ctpCfg.accent}.theme.css")}
          }
        ''
      else
        readFile (cssDir + "/catppuccin-${ctpCfg.flavor}-${ctpCfg.accent}.theme.css");
  };
}
