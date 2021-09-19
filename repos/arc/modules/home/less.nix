{ config, pkgs, lib, ... }: with lib; let
  cfg = config.programs.less;
  lesskey = conf: with pkgs; stdenvNoCC.mkDerivation {
    name = "lesskey";
    conf = writeText "lesskey" conf;
    nativeBuildInputs = [buildPackages.less];

    unpackPhase = "true";
    installPhase = ''
      lesskey -o $out $conf
    '';
  };
in {
  options.programs.less = {
    enable = mkEnableOption "less";
    lesskey = {
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file.".less" = mkIf (cfg.lesskey.extraConfig != "") {
      source = lesskey cfg.lesskey.extraConfig;
    };
  };
}
