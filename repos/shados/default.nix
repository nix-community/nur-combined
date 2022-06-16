{ pkgs ? import <nixpkgs> { } }:
let
  nixpkgsPath = pkgs.path;
  pins = import ./nix/sources.nix nixpkgsPath pkgs.targetPlatform.system;
in
let repo = rec {
  lib = import ./lib { inherit pkgs repo; };
  modules = import ./modules;
  overlays = import ./overlays;

  ## Packages

  arcconf = pkgs.callPackage ./pkgs/arcconf {
    inherit pins;
  };

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

  firefox-history-merger = pkgs.callPackage ./pkgs/firefox-history-merger {
    inherit pins;
  };

  json-yaml = pkgs.callPackage ./pkgs/json-yaml {
    inherit pins;
  };

  loudgain = pkgs.callPackage ./pkgs/loudgain {
    inherit pins;
  };

  tagsistant = pkgs.callPackage ./pkgs/tagsistant {
    inherit pins;
  };

  tmm = pkgs.callPackage ./pkgs/tmm { };

  urxvt-config-reload = pkgs.callPackage ./pkgs/urxvt-config-reload {
    inherit (pkgs.perlPackages) AnyEvent LinuxFD CommonSense SubExporter
      DataOptList ParamsUtil SubInstall;
    inherit pins;
  };
  urxvtconfig = pkgs.libsForQt5.callPackage ./pkgs/urxvtconfig {
    inherit (pkgs.xorg) libXft;
    inherit pins;
  };

  # waterfox = pkgs.wrapFirefox waterfox-unwrapped {
  #   browserName = "waterfox";
  #   nameSuffix = "";
  # };
  # waterfox-unwrapped = pkgs.callPackage ./pkgs/waterfox {
  #   inherit firefox-common nixpkgsPath;
  # };
}; in repo
