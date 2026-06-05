# to preview fonts:
# - `font-manager` (gui)
#   - useful to determine official name; codepoint support
# docs:
# - <https://slatecave.net/notebook/fontconfig/>
# debugging:
# - `fc-conflist` -> show all config files loaded
{ config, lib, pkgs, ... }:
let
  # see: <repo:nixos/nixpkgs:nixos/modules/config/fonts/fontconfig.nix>
  # and: <repo:nixos/nixpkgs:pkgs/development/libraries/fontconfig/make-fonts-cache.nix>
  # nixpkgs creates a fontconfig cache, which covers 99% of apps.
  # if build-time caching fails for some reason, then fonts are cached at runtime, in ~/.cache/fontconfig,
  # and that needs to either be added to the sandbox of *every* app,
  # or font-heavy apps are several *seconds* slower to launch.

  noUserCacheConf = pkgs.runCommand "etc-fonts-fonts.conf-no-user" {} ''
    cp ${pkgs.fontconfig.out}/etc/fonts/fonts.conf .
    substituteInPlace fonts.conf \
      --replace-fail '<cachedir prefix="xdg">fontconfig</cachedir>' "" \
      --replace-fail '<cachedir>/var/cache/fontconfig</cachedir>' ""
    mkdir -p $out/etc/fonts
    cp fonts.conf $out/etc/fonts/fonts.conf
  '';
in
{
  sane.programs.fontconfig = {
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
        "Monaspace Argon"  #< thin, slightly handwriting-ish
        # "Monaspace Neon"  #< typewriter style
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

    fontconfig.confPackages = lib.mkBefore [
      # XXX(2024-12-18): electron apps (signal-desktop, discord) duplicate the entire font cache (1-2MB) to ~/.cache/fontconfig
      # just to update a tiny section (4KB).
      # patch instead to not have a user font cache. they will work, but complain "Fontconfig error: No writable cache directories".
      # proper fix: see if electron apps need some specific font i'm missing, or are just being dumb?
      noUserCacheConf
    ];

    #vvv enables dejavu_fonts, freefont_ttf, gyre-fonts, liberation_ttf, unifont, noto-fonts-emoji
    enableDefaultPackages = false;
    packages = with pkgs; [
      # TODO: reduce this font set.
      # - probably need only one of dejavu/freefont/liberation
      dejavu_fonts            # 10 MiB; DejaVu {Sans,Serif,Sans Mono,Math TeX Gyre}; also available as a NerdFonts (Sans Mono only)
      # font-awesome            #  2 MiB; Font Awesome 6 {Free,Brands}
      freefont_ttf            # 11 MiB; Free{Mono,Sans,Serif}
      gyre-fonts              #  4 MiB; Tex Gyre *; ttf substitutes for standard PostScript fonts
      # hack-font               #  1 MiB; Hack; also available as a NerdFonts
      liberation_ttf          # 4 MiB; Liberation {Mono,Sans,Serif}; also available as a NerdFonts
      monaspace               # 20 MiB;
      noto-fonts-color-emoji  # 10 Mib; Noto Color Emoji
      unifont                 # 16 MiB; Unifont; provides LOTS of unicode coverage

      # nerdfonts takes popular open fonts and patches them to support a wider range of glyphs, notably emoji.
      # any nerdfonts font includes icons such as these:
      # - 󱊥 (battery charging)
      # - 󰃝 (brightness)
      # -  (gps / crosshairs)
      # - 󰎈 (music note)
      # - 󰍦 (message bubble)
      # - 󰏲 (phone)
      # -  (weather/sun-behind-clouds)
      # i use these icons mostly in conky, swaync.
      #
      # nerdfonts is very heavy. each font is 20-900 MiB (2 MiB per "variation")
      # lots of redundant data inside there, but no deduplication except whatever nix or the fs does implicitly.
      #
      # good terminal/coding font: grab via nerdfonts for more emoji/unicode support
      nerd-fonts.hack  # 26 MiB
      nerd-fonts.noto  # 861 MiB
    ];
  };
}
