{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.u-boot-pinephone-pro;
in
{
  sane.programs.u-boot-pinephone-pro = {
    packageUnwrapped = pkgs.runCommand "u-boot-pinephone-pro-program" {
      preferLocalBuild = true;
    } ''
      install -Dm644 ${pkgs.u-boot-pinephone-pro}/idbloader.img $out/share/boot/idbloader.img
      install -Dm644 ${pkgs.u-boot-pinephone-pro}/u-boot.itb $out/share/boot/u-boot.itb
      install -Dm755 ${./install-u-boot} $out/bin/install-u-boot
      # ln -sv $out/bin/install-u-boot $out/share/boot/install-u-boot
    '';
    sandbox.autodetectCliPaths = "existingFile";
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [
    "/share/boot"
  ];
}
