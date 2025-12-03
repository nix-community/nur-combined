{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    ;
  cfg = config.personaj.gaming;

in
{
  options.personaj.gaming = {
    enable = mkEnableOption "gaming profile on Home-Manager";
    enableProtontricks = mkEnableOption "Protontricks";
    extraPkgs = mkOption {
      default = [ ];
      type = types.listOf types.package;
      description = ''
        List of extra packages to install
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enableProtontricks {
      home.packages = with pkgs; [
        protontricks
        winetricks
      ];
    })
    { home.packages = cfg.extraPkgs; }
  ]);

}
