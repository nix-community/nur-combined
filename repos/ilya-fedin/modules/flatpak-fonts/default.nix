/*

Configuration files are linked to /etc/fonts/conf.d/

This module generates a package containing configuration files and link it in /etc/fonts.

Fontconfig reads files in folder name / file name order, so the number prepended to the configuration file name decide the order of parsing.
Low number means high priority.

*/

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.fonts.fontconfig;

  fcBool = x: "<bool>" + (boolToString x) + "</bool>";
  pkg = pkgs.fontconfig;

  fontDir = pkgs.runCommand "fonts" { preferLocalBuild = true; } ''
    mkdir -p "$out"
    font_regexp='.*\.\(ttf\|ttc\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
    find ${toString config.fonts.fonts} -regex "$font_regexp" \
      -exec cp -rn --no-preserve=mode,ownership '{}' "$out" \;
  '';

  # configuration file to read fontconfig cache
  # priority 0
  cacheConf  = makeCacheConf {};

  # generate the font cache setting file
  # When cross-compiling, we can’t generate the cache, so we skip the
  # <cachedir> part. fontconfig still works but is a little slower in
  # looking things up.
  makeCacheConf = { }:
    let
      makeCache = fontconfig: pkgs.makeFontsCache { inherit fontconfig; fontDirectories = [ fontDir ]; };
      cache     = makeCache pkgs.fontconfig;
      cache32   = makeCache pkgs.pkgsi686Linux.fontconfig;
    in
    pkgs.writeText "fc-00-nixos-cache.conf" ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
      <fontconfig>
        <!-- Font directories -->
        <dir>${fontDir}</dir>
        ${optionalString (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) ''
        <!-- Pre-generated font caches -->
        <cachedir>${cache}</cachedir>
        ${optionalString (pkgs.stdenv.isx86_64 && cfg.cache32Bit) ''
          <cachedir>${cache32}</cachedir>
        ''}
        ''}
      </fontconfig>
    '';

  # rendering settings configuration file
  # priority 10
  renderConf = pkgs.writeText "fc-10-nixos-rendering.conf" ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
    <fontconfig>

      <!-- Default rendering settings -->
      <match target="pattern">
        <edit mode="append" name="hinting">
          ${fcBool cfg.hinting.enable}
        </edit>
        <edit mode="append" name="autohint">
          ${fcBool cfg.hinting.autohint}
        </edit>
        <edit mode="append" name="hintstyle">
          <const>hintslight</const>
        </edit>
        <edit mode="append" name="antialias">
          ${fcBool cfg.antialias}
        </edit>
        <edit mode="append" name="rgba">
          <const>${cfg.subpixel.rgba}</const>
        </edit>
        <edit mode="append" name="lcdfilter">
          <const>lcd${cfg.subpixel.lcdfilter}</const>
        </edit>
      </match>

    </fontconfig>
  '';

  # local configuration file
  localConf = pkgs.writeText "fc-local.conf" cfg.localConf;

  # default fonts configuration file
  # priority 52
  defaultFontsConf =
    let genDefault = fonts: name:
      optionalString (fonts != []) ''
        <alias binding="same">
          <family>${name}</family>
          <prefer>
          ${concatStringsSep ""
          (map (font: ''
            <family>${font}</family>
          '') fonts)}
          </prefer>
        </alias>
      '';
    in
    pkgs.writeText "fc-52-nixos-default-fonts.conf" ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
    <fontconfig>

      <!-- Default fonts -->
      ${genDefault cfg.defaultFonts.sansSerif "sans-serif"}

      ${genDefault cfg.defaultFonts.serif     "serif"}

      ${genDefault cfg.defaultFonts.monospace "monospace"}

      ${genDefault cfg.defaultFonts.emoji "emoji"}

    </fontconfig>
  '';

  # bitmap font options
  # priority 53
  rejectBitmaps = pkgs.writeText "fc-53-no-bitmaps.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>

    ${optionalString (!cfg.allowBitmaps) ''
    <!-- Reject bitmap fonts -->
    <selectfont>
      <rejectfont>
        <pattern>
          <patelt name="scalable"><bool>false</bool></patelt>
        </pattern>
      </rejectfont>
    </selectfont>
    ''}

    <!-- Use embedded bitmaps in fonts like Calibri? -->
    <match target="font">
      <edit name="embeddedbitmap" mode="assign">
        ${fcBool cfg.useEmbeddedBitmaps}
      </edit>
    </match>

    </fontconfig>
  '';

  # reject Type 1 fonts
  # priority 53
  rejectType1 = pkgs.writeText "fc-53-nixos-reject-type1.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>

    <!-- Reject Type 1 fonts -->
    <selectfont>
      <rejectfont>
        <pattern>
          <patelt name="fontformat"><string>Type 1</string></patelt>
        </pattern>
      </rejectfont>
    </selectfont>

    </fontconfig>
  '';

  # fontconfig configuration package
  confPkg = pkgs.runCommand "fontconfig-conf" {
    preferLocalBuild = true;
  } ''
    dst=$out/etc/fonts/conf.d
    mkdir -p $dst

    # fonts.conf
    ln -s ${pkg.out}/etc/fonts/fonts.conf \
          $dst/../fonts.conf
    # TODO: remove this legacy symlink once people stop using packages built before #95358 was merged
    mkdir -p $out/etc/fonts/2.11
    ln -s /etc/fonts/fonts.conf \
          $out/etc/fonts/2.11/fonts.conf

    # fontconfig default config files
    ln -s ${pkg.out}/etc/fonts/conf.d/*.conf \
          $dst/

    # 00-nixos-cache.conf
    ln -s ${cacheConf}  $dst/00-nixos-cache.conf

    # 10-nixos-rendering.conf
    ln -s ${renderConf}       $dst/10-nixos-rendering.conf

    # 50-user.conf
    ${optionalString (!cfg.includeUserConf) ''
    rm $dst/50-user.conf
    ''}

    # local.conf (indirect priority 51)
    ${optionalString (cfg.localConf != "") ''
    ln -s ${localConf}        $dst/../local.conf
    ''}

    # 52-nixos-default-fonts.conf
    ln -s ${defaultFontsConf} $dst/52-nixos-default-fonts.conf

    # 53-no-bitmaps.conf
    ln -s ${rejectBitmaps} $dst/53-no-bitmaps.conf

    ${optionalString (!cfg.allowType1) ''
    # 53-nixos-reject-type1.conf
    ln -s ${rejectType1} $dst/53-nixos-reject-type1.conf
    ''}
  '';
in
{

  config = mkIf cfg.enable {
    fonts.fontconfig.confPackages = [ confPkg ];
    fileSystems."/usr/share/fonts" = {
      device = "${fontDir}";
      fsType = "none";
      options = [ "bind" ];
    };
  };

}
