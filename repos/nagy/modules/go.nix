{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.go;
in
{
  options.nagy.go = {
    enable = lib.mkEnableOption "go config";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.go
      pkgs.gopls
    ];
  };
}
