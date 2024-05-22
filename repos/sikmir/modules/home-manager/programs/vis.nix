{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.programs.vis;
  configDir = "${config.home.homeDirectory}/.config/vis";
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.vis = {
    enable = mkEnableOption "A vim like editor";

    package = mkOption {
      default = pkgs.vis;
      defaultText = literalExpression "pkgs.vis";
      description = "vis package to install.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file."${configDir}/visrc.lua".text = ''
      -- load standard vis module, providing parts of the Lua API
      require('vis')

      vis.events.subscribe(vis.events.WIN_OPEN, function(win)
        -- Your per window configuration options e.g.
        vis:command('set number on')
        vis:command('set tabwidth 4')
        vis:command('set theme zenburn')
      end)
    '';
  };
}
