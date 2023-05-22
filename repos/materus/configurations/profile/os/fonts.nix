{ config, pkgs, lib, materusPkgs, ... }:
let
  packages = config.materus.profile.packages;
  cfg = config.materus.profile.fonts;
in
{
  options.materus.profile.fonts.enable = materusPkgs.lib.mkBoolOpt false "Enable materus font settings for OS";

  config = lib.mkIf cfg.enable {

    fonts.fonts = packages.list.fonts ++ packages.list.moreFonts;
    fonts.enableDefaultFonts = lib.mkForce true;
    
    fonts.fontconfig.enable = lib.mkForce true;
    fonts.fontconfig.cache32Bit = lib.mkForce  true;

    fonts.fontconfig.defaultFonts.sansSerif =  [ "Noto Sans" "DejaVu Sans" "WenQuanYi Zen Hei" "Noto Color Emoji" ];
    fonts.fontconfig.defaultFonts.serif =  [ "Noto Serif" "DejaVu Serif" "WenQuanYi Zen Hei" "Noto Color Emoji" ];
    fonts.fontconfig.defaultFonts.emoji =  [ "Noto Color Emoji" "OpenMoji Color" ];
    fonts.fontconfig.defaultFonts.monospace =  [ "FiraCode Nerd Font Mono" "Noto Sans Mono" "WenQuanYi Zen Hei Mono" ];

    fonts.fontDir.enable = lib.mkForce true;
  };
}
