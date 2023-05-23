{ config, lib, pkgs, materusPkgs, ... }:
let
  cfg = config.materus.profile.editor.code;
in
{
  options.materus.profile.editor.code.enable = materusPkgs.lib.mkBoolOpt config.materus.profile.enableDesktop "Enable VSCodium with materus cfg";

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.vscodium;
      mutableExtensionsDir = lib.mkDefault true;
    };
    materus.profile.fonts.enable = lib.mkDefault true;
  };
}
