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

  cfg = config.my.home.lorri;
in {
  options.my.home.lorri = {
    enable = (mkEnableOption "lorri daemon setup") // {default = true;};
  };

  config = mkIf cfg.enable {
    services.lorri.enable = true;
    programs.direnv = {
      enable = true;
      # FIXME: proper file, not lorri.nix
      nix-direnv = {
        enable = true;
      };
    };
  };
}
