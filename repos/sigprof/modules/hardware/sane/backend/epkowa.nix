{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.sigprof.hardware.sane.backend.epkowa;
in {
  options.sigprof.hardware.sane.backend.epkowa = {
    enable = mkEnableOption "the unfree 'epkowa' backend for some Epson scanners";
    package = mkPackageOption pkgs "epkowa" {};
  };

  config = mkIf cfg.enable {
    hardware.sane.extraBackends = [cfg.package];
    sigprof.nixpkgs.permittedUnfreePackages = [
      "iscan"
      "iscan-data"
      "iscan-ds"
      "iscan-gt"
      "iscan-gt-f720-bundle"
      "iscan-gt-s600-bundle"
      "iscan-gt-s650-bundle"
      "iscan-gt-s80-bundle"
      "iscan-gt-x750-bundle"
      "iscan-gt-x770-bundle"
      "iscan-gt-x820-bundle"
      "iscan-nt-bundle"
      "iscan-perfection-v550-bundle"
      "iscan-v330-bundle"
      "iscan-v370-bundle"
    ];
  };
}
