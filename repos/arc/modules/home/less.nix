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
    home.file.".lesskey" = {
      target = ".less";
      source = pkgs.callPackage lesskey { } cfg.keys;
    };
  };
}
