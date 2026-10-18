{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.galgamemanager;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  galgamemanager = myCallPackage ../../pkgs/galgamemanager { };
in
{
  options.programs.galgamemanager = {
    enable = lib.mkEnableOption "GalgameManager, a Tauri-based galgame manager with playtime statistics, config and save sync";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ galgamemanager ];
  };
}
