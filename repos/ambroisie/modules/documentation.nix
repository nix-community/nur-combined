{ config, lib, ... }:
let
  cfg = config.my.module.documentation;

  # I usually want everything enabled at once, but keep it customizable
  defaultToGlobal = description: lib.mkEnableOption description // {
    default = cfg.enable;
  };
in
{
  options.my.module.documentation = with lib.my; {
    enable = mkDisableOption "Documentation integration";

    dev.enable = defaultToGlobal "Documentation aimed at developers";

    info.enable = defaultToGlobal "Documentation aimed at developers";

    man.enable = defaultToGlobal "Documentation aimed at developers";

    nixos.enable = defaultToGlobal "NixOS documentation";
  };

  config.documentation = {
    enable = cfg.enable;

    dev.enable = cfg.dev.enable;

    info.enable = cfg.info.enable;

    man = {
      enable = cfg.man.enable;
      generateCaches = true;
    };

    nixos.enable = cfg.nixos.enable;
  };
}
