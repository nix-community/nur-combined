{ config, pkgs, lib, ... }: with lib; let
  cfg = config.programs.less;
  lesskey = { stdenvNoCC, less }: conf: stdenvNoCC.mkDerivation {
    name = "lesskey";
    nativeBuildInputs = singleton less;
    passAsFile = singleton "conf";
    inherit conf;

    buildCommand = ''
      lesskey -o $out $confPath
    '';
  };
in {
  options.programs.less = {
    lesskey.enable = mkEnableOption "lesskey file";
  };
  config = mkIf (cfg.enable or false && !cfg.lesskey.enable) {
    home.file.".lesskey" = let
      binary = pkgs.callPackage lesskey { } cfg.keys;
    in {
      target = ".less";
      source = if lib.versionOlder cfg.package.version "710"
        then binary
        else builtins.toFile "lesskey" cfg.keys;
    };
  };
}
