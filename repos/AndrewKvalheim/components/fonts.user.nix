{ lib, pkgs, ... }:

let
  inherit (lib) fileContents filter hasPrefix hasSuffix splitString;
  inherit (pkgs) fontconfig noto-fonts runCommand;

  # Workaround for unicode-org/last-resort-font#3
  noto = splitString "\n" (fileContents (runCommand "noto-families" { nativeBuildInputs = [ fontconfig ]; } ''
    fc-scan --format '%{family}\n' ${noto-fonts}'/share/fonts/noto' | sort --unique > "$out"
  ''));
  notoMono = filter (hasSuffix "Mono") noto ++ [ "Noto Sans Mono CJK JP" ];
  notoSans = filter (f: hasPrefix "Noto Sans" f && ! hasSuffix "Mono" f) noto ++ [ "Noto Sans CJK JP" ];
  notoSerif = filter (f: hasPrefix "Noto Serif" f && ! hasSuffix "Mono" f) noto ++ [ "Noto Serif CJK JP" ];
in
{
  nixpkgs.config.allowUnfreePackages = [
    "affine-font"
    "corefonts"
  ];

  home.packages = with pkgs; [
    affine-font
    cc-icons-unicode
    corefonts
    iosevka-custom.mono
    iosevka-custom.proportional
    iosevka-custom.term
    last-resort
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    roboto
    roboto-mono
    source-serif-pro
  ];

  dconf.settings = {
    "org/gnome/desktop/interface".font-name = "Roboto 11";
    "org/gnome/desktop/interface".document-font-name = "Roboto 11";
    "org/gnome/desktop/interface".monospace-font-name = "Iosevka Custom Mono 10";
    "org/gnome/desktop/wm/preferences".titlebar-font = "Roboto Bold 11";
  };

  fonts.fontconfig = let fallback = "Last Resort High-Efficiency"; in {
    enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji" fallback ];
      monospace = [ "Iosevka Custom Mono" ] ++ notoMono ++ [ "Symbols Nerd Font Mono" "Unifont" fallback ];
      sansSerif = [ "Roboto" ] ++ notoSans ++ [ "CCIconsUnicode" "Symbols Nerd Font" fallback ];
      serif = [ "Source Serif Pro" ] ++ notoSerif ++ [ "CCIconsUnicode" "Symbols Nerd Font" fallback ];
    };
  };
}
