{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.boot;
in
{
  options.nixcfg.boot.enable = lib.mkEnableOption "boot defaults (systemd-boot limit, appimage binfmt, plymouth)";

  config = lib.mkIf cfg.enable {
    boot = {
      loader.systemd-boot.configurationLimit = lib.mkIf config.boot.loader.systemd-boot.enable 3;
      binfmt.registrations.appimage = {
        wrapInterpreterInShell = false;
        interpreter = lib.getExe pkgs.appimage-run;
        recognitionType = "magic";
        offset = 0;
        mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
        magicOrExtension = ''\x7fELF....AI\x02'';
      };
      plymouth.enable = true;
    };
  };
}
