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
      "iscan-gt-f720-bundle"
      "iscan-nt-bundle"
      "iscan-gt-s650-bundle"
      "iscan-gt-s80-bundle"
      "iscan-v330-bundle"
      "iscan-v370-bundle"
      "iscan-gt-x820-bundle"
      "iscan-gt-x770-bundle"
      "iscan-data"
    ];
  };
}
