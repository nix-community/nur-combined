{ config, lib, pkgs, ... }:

let
  inherit (lib) any;

  # Duplicated from <nixpkgs/nixos/modules/config/i18n.nix>
  glibcLocalesDefault = pkgs.glibcLocales.override {
    allLocales = any (x: x == "all") config.i18n.supportedLocales;
    locales = config.i18n.supportedLocales;
  };
in
{
  i18n = {
    glibcLocales = glibcLocalesDefault.overrideAttrs (glibcLocales: {
      patchPhase = glibcLocales.patchPhase or "" + ''
        cp --verbose '${./assets}/en_US@aspirational.locale' 'localedata/locales/en_US@aspirational'
        echo 'en_US.UTF-8@aspirational/UTF-8 \' >> 'localedata/SUPPORTED'
      '';
    });

    extraLocaleSettings.LANG = "en_US.UTF-8@aspirational";
  };

  time.timeZone = "America/Los_Angeles";
}
