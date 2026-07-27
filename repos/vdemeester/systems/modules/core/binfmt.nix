{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf types;
  cfg = config.modules.core.binfmt;
in
{
  options = {
    modules.core.binfmt = {
      enable = mkEnableOption "Register extra emulated systems using binfmt";
    };
  };
  config = mkIf cfg.enable {
    boot = {
      binfmt.registrations = {
        s390x-linux = {
          # interpreter = getEmulator "s390x-linux";
          interpreter = "${pkgs.qemu}/bin/qemu-s390x";
          magicOrExtension = ''\x7fELF\x02\x02\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x16'';
          mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff'';
        };
      };
      binfmt.emulatedSystems = [
        "armv6l-linux"
        "armv7l-linux"
        "aarch64-linux"
        "powerpc64le-linux"
      ];
    };
  };
}
