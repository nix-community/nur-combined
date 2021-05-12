{ pkgs ? import <nixpkgs> { } }:
let
  nixpkgsPath = pkgs.path;
in
let repo = rec {
  lib = import ./lib { inherit pkgs repo; };
  modules = import ./modules;
  overlays = import ./overlays;

  ## Packages

  firefox-common = opts: with pkgs; callPackage
    (import (nixpkgsPath + /pkgs/applications/networking/browsers/firefox/common.nix) opts)
    { libpng = libpng_apng;
      gnused = gnused_422;
      inherit (darwin.apple_sdk.frameworks) CoreMedia ExceptionHandling
                                            Kerberos AVFoundation MediaToolbox
                                            CoreLocation Foundation AddressBook;
      inherit (darwin) libobjc;

      enableOfficialBranding = false;
      privacySupport = true;
    };

  json-yaml = pkgs.callPackage ./pkgs/json-yaml { };

  loudgain = pkgs.callPackage ./pkgs/loudgain { };

  rxvt_unicode_24bit = pkgs.callPackage ./pkgs/rxvt_unicode_24bit {
    perlSupport = true;
    gdkPixbufSupport = true;
    unicode3Support = true;
  };

  tagsistant = pkgs.callPackage ./pkgs/tagsistant { };

  urxvt-config-reload = pkgs.callPackage ./pkgs/urxvt-config-reload {
    inherit (pkgs.perlPackages) AnyEvent LinuxFD CommonSense SubExporter
      DataOptList ParamsUtil SubInstall;
  };
  urxvtconfig = pkgs.libsForQt5.callPackage ./pkgs/urxvtconfig {
    inherit (pkgs.xorg) libXft;
  };

  # waterfox = pkgs.wrapFirefox waterfox-unwrapped {
  #   browserName = "waterfox";
  #   nameSuffix = "";
  # };
  # waterfox-unwrapped = pkgs.callPackage ./pkgs/waterfox {
  #   inherit firefox-common nixpkgsPath;
  # };
}; in repo
