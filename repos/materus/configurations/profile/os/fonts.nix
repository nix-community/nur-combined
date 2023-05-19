{ config, pkgs, lib, materusPkgs, ... }:
let
  packages = config.materus.profile.packages;
  cfg = config.materus.profile.fonts;
in
{
  options.materus.profile.fonts.enable = materusPkgs.lib.mkBoolOpt false "Enable materus font settings for OS";

  config = lib.mkIf cfg.enable {

    fonts.fonts = packages.list.fonts ++ packages.list.moreFonts;
    fonts.enableDefaultFonts = lib.mkDefault true;
    
    fonts.fontconfig.enable = lib.mkDefault true;
    fonts.fontconfig.cache32Bit = lib.mkDefault  true;

    fonts.fontconfig.defaultFonts.sansSerif = lib.mkDefault [ "Noto Sans" "DejaVu Sans" "WenQuanYi Zen Hei" "Noto Color Emoji" ];
    fonts.fontconfig.defaultFonts.serif = lib.mkDefault [ "Noto Serif" "DejaVu Serif" "WenQuanYi Zen Hei" "Noto Color Emoji" ];
    fonts.fontconfig.defaultFonts.emoji = lib.mkDefault [ "Noto Color Emoji" "OpenMoji Color" ];
    fonts.fontconfig.defaultFonts.monospace = lib.mkDefault [ "FiraCode Nerd Font Mono" "Noto Sans Mono" "WenQuanYi Zen Hei Mono" ];

    fonts.fontDir.enable = lib.mkDefault true;
  };
}
