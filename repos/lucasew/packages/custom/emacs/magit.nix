{pkgs, lib, config, ...}:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.magit.enable = mkEnableOption "magit";
  config = mkIf config.magit.enable {
    plugins = with pkgs.emacsPackages; [ magit ];
  };
}
