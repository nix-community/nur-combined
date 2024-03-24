# to preview fonts:
# - `font-manager` (gui)
#   - useful to determine official name; codepoint support
# docs:
# - <https://slatecave.net/notebook/fontconfig/>
# debugging:
# - `fc-conflist` -> show all config files loaded
{ config, lib, pkgs, ... }:
let
  # nerdfonts takes popular open fonts and patches them to support a wider range of glyphs, notably emoji.
  # any nerdfonts font includes icons such as these:
  # - 󱊥 (battery charging)
  # - 󰃝 (brightness)
  # -  (gps / crosshairs)
  # - 󰎈 (music note)
  # - 󰍦 (message bubble)
  # - 󰏲 (phone)
  # -  (weather/sun-behind-clouds)
  # used particularly by sxmo utilities, but also a few of my own (e.g. conky)
  #
  # nerdfonts is very heavy. each font is 20-900 MiB (2 MiB per "variation")
  # lots of redundant data inside there, but no deduplication except whatever nix or the fs does implicitly.
  wantedNerdfonts = [
    # used explicitly by SXMO
    # "DejaVuSansMono"  # 25 MiB
    # good terminal/coding font. grab via nerdfonts for more emoji/unicode support
    "Hack"  # 26 MiB
    "Noto"  # 861 MiB
  ];
  nerdfontPkgs = builtins.map
    (f: pkgs.nerdfonts.override { fonts = [ f ]; })
    wantedNerdfonts;
in
{
  sane.programs.fontconfig = {
    sandbox.method = "bwrap";  # TODO:sandbox: untested
    sandbox.autodetectCliPaths = "existingOrParent";  #< this might be overkill; or, how many programs reference fontconfig internally?

    # persist.byStore.plaintext = [
    #   # < 10 MiB. however, nixos generates its own fontconfig cache at build time now.
    #   ".cache/fontconfig"
    # ];
  };

  fonts = lib.mkIf config.sane.programs.fontconfig.enabled {
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      emoji = [
        "Noto Color Emoji"
        # "Font Awesome 6 Free"
        # "Font Awesome 6 Brands"
      ];
      monospace = [
        "Hack Nerd Font Propo"
        # "DejaVuSansM Nerd Font Propo"
        "NotoMono Nerd Font Propo"
      ];
      serif = [
        "NotoSerif Nerd Font"
        "DejaVu Serif"
      ];
      sansSerif = [
        "NotoSans Nerd Font"
        "DejaVu Sans"
      ];
    };
    #vvv enables dejavu_fonts, freefont_ttf, gyre-fonts, liberation_ttf, unifont, noto-fonts-emoji
    enableDefaultPackages = false;
    packages = with pkgs; [
      # TODO: reduce this font set.
      # - probably need only one of dejavu/freefont/liberation
      dejavu_fonts  # 10 MiB; DejaVu {Sans,Serif,Sans Mono,Math TeX Gyre}; also available as a NerdFonts (Sans Mono only)
      # font-awesome  #  2 MiB; Font Awesome 6 {Free,Brands}
      freefont_ttf  # 11 MiB; Free{Mono,Sans,Serif}
      gyre-fonts    #  4 MiB; Tex Gyre *; ttf substitutes for standard PostScript fonts
      # hack-font     #  1 MiB; Hack; also available as a NerdFonts
      liberation_ttf # 4 MiB; Liberation {Mono,Sans,Serif}; also available as a NerdFonts
      noto-fonts-color-emoji  # 10 Mib; Noto Color Emoji
      unifont       # 16 MiB; Unifont; provides LOTS of unicode coverage
    ] ++ nerdfontPkgs;
  };
}
