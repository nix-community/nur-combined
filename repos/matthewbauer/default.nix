{ pkgs ? import <nixpkgs> (builtins.removeAttrs args ["pkgs"] )

# needed so nix will put them in args list
# do not use directly!
, config ? null, localSystem ? null, crossSystem ? null, system ? null

, ... } @ args:

let
  inherit (pkgs) callPackage;

  self = {
    tensorflow-bin = pkgs.pythonPackages.callPackage ./tensorflow-bin {};
    firefox-bin = callPackage ./firefox-bin {
      gconf = pkgs.gnome2.GConf;
      inherit (pkgs.gnome2) libgnome libgnomeui;
      inherit (pkgs.gnome3) defaultIconTheme;
    };
    tor-browser-bundle-bin = callPackage ./tor-browser-bundle-bin {};
    thunderbird-bin = callPackage ./thunderbird-bin {
      gconf = pkgs.gnome2.GConf;
      inherit (pkgs.gnome2) libgnome libgnomeui;
      inherit (pkgs.gnome3) defaultIconTheme;
    };
    iosevka-bin = callPackage ./iosevka-bin {};
    frostwire-bin = callPackage ./frostwire-bin {};
  };

  aliases = {
    torbrowser = self.tor-browser-bundle-bin;
  };

  firefox-devedition-bin-unwrapped = self.firefox-bin.override {
    channel = "devedition";
    generated = import ./firefox-bin/devedition_sources.nix;
  };

  firefox-beta-bin-unwrapped = self.firefox-bin.override {
    channel = "beta";
    generated = import ./firefox-bin/beta_sources.nix;
  };

  overrides = rec {
    firefox-bin = pkgs.wrapFirefox self.firefox-bin {
      browserName = "firefox";
      name = "firefox-bin-" +
        (builtins.parseDrvName self.firefox-bin.name).version;
      desktopName = "Firefox";
    };

    firefox-beta-bin = pkgs.wrapFirefox firefox-beta-bin-unwrapped {
      browserName = "firefox";
      name = "firefox-beta-bin-" +
        (builtins.parseDrvName firefox-beta-bin-unwrapped.name).version;
      desktopName = "Firefox Beta";
    };

    firefox-devedition-bin = pkgs.wrapFirefox firefox-devedition-bin-unwrapped {
      browserName = "firefox";
      nameSuffix = "-devedition";
      name = "firefox-devedition-bin-" +
        (builtins.parseDrvName firefox-devedition-bin-unwrapped.name).version;
      desktopName = "Firefox DevEdition";
    };
  };

in self // overrides // aliases
