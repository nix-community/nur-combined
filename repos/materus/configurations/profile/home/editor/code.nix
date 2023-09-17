{ config, lib, pkgs, materusPkgs, ... }:
let
  cfg = config.materus.profile.editor.code;
in
{
  options.materus.profile.editor.code.enable = materusPkgs.lib.mkBoolOpt config.materus.profile.enableDesktop "Enable VSCodium with materus cfg";
  options.materus.profile.editor.code.fhs.enable = materusPkgs.lib.mkBoolOpt false "Use fhs vscodium";
  options.materus.profile.editor.code.fhs.packages = lib.mkOption { default = (ps: []);};
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = lib.mkDefault true;
      package = lib.mkDefault (if (cfg.fhs.enable)  then (pkgs.vscodium.fhsWithPackages cfg.fhs.packages) else pkgs.vscodium);
      mutableExtensionsDir = lib.mkDefault true;
    };
    materus.profile.fonts.enable = lib.mkDefault true;
  };
}
