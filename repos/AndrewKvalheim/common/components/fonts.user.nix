{ config, lib, pkgs, ... }:

let
  inherit (lib) concatStrings mkOption;
  inherit (lib.types) listOf str;
in
{
  # Pending https://github.com/nix-community/home-manager/pull/2732
  options.fonts.fontconfig.defaultFonts = {
    emoji = mkOption { type = listOf str; };
    monospace = mkOption { type = listOf str; };
    sansSerif = mkOption { type = listOf str; };
    serif = mkOption { type = listOf str; };
  };

  config = {
    allowedUnfree = [
      "affine-font"
      "corefonts"
    ];

    home.packages = with pkgs; [
      affine-font
      corefonts
      iosevka-custom.mono
      iosevka-custom.proportional
      iosevka-custom.term
      noto-fonts-color-emoji
      roboto
      source-serif-pro
    ];

    dconf.settings = {
      "org/gnome/desktop/interface".font-name = "Roboto 11";
      "org/gnome/desktop/interface".document-font-name = "Roboto 11";
      "org/gnome/desktop/interface".monospace-font-name = "Iosevka Custom Mono 10";
      "org/gnome/desktop/wm/preferences".titlebar-font = "Roboto Bold 11";
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts.emoji = [ "Noto Color Emoji" ];
      defaultFonts.monospace = [ "Iosevka Custom Mono" ];
      defaultFonts.sansSerif = [ "Roboto" ];
      defaultFonts.serif = [ "Source Serif Pro" ];
    };

    # Pending https://github.com/nix-community/home-manager/pull/2732
    xdg.configFile."fontconfig/conf.d/52-hm-default-fonts.conf".text =
      let mkPrefer = query: prefer: ''
        <alias binding="same">
          <family>${query}</family>
          <prefer>${concatStrings (map (p: "<family>${p}</family>") prefer)}</prefer>
        </alias>
      ''; in ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'><fontconfig>
        ${mkPrefer "emoji" config.fonts.fontconfig.defaultFonts.emoji}
        ${mkPrefer "monospace" config.fonts.fontconfig.defaultFonts.monospace}
        ${mkPrefer "sans-serif" config.fonts.fontconfig.defaultFonts.sansSerif}
        ${mkPrefer "serif" config.fonts.fontconfig.defaultFonts.serif}
        </fontconfig>
      '';
  };
}
