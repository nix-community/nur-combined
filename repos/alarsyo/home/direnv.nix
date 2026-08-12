{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.direnv;
in {
  options.my.home.direnv = {
    enable = (mkEnableOption "setup direnv usage") // {default = true;};
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
