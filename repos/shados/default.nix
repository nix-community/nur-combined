{
  pkgs ? import <nixpkgs> { },
}:
let
  nixpkgsPath = pkgs.path;
  pins = import ./nix/sources.nix nixpkgsPath pkgs.targetPlatform.system;
  naersk = pkgs.callPackage pins.naersk { };
in
let
  repo = rec {
    lib = import ./lib { inherit pkgs repo; };
    modules = import ./modules;
    overlays = import ./overlays;

    ## Packages

    audio-async-loopback = pkgs.callPackage ./pkgs/audio-async-loopback {
      inherit pins;
    };

    arcconf = pkgs.callPackage ./pkgs/arcconf {
    };

    bootloadhid = pkgs.callPackage ./pkgs/bootloadhid {
    };

    broadcast-box = pkgs.callPackage ./pkgs/broadcast-box {
      inherit pins;
    };

    chromium-launcher = pkgs.callPackage ./pkgs/chromium-launcher {
      inherit pins;
    };

    dualsensectl = pkgs.callPackage ./pkgs/dualsensectl {
      inherit pins;
    };

    firefox-common =
      opts:
      with pkgs;
      callPackage (import (nixpkgsPath + /pkgs/applications/networking/browsers/firefox/common.nix) opts)
        {
          libpng = libpng_apng;
          gnused = gnused_422;
          inherit (darwin.apple_sdk.frameworks)
            CoreMedia
            ExceptionHandling
            Kerberos
            AVFoundation
            MediaToolbox
            CoreLocation
            Foundation
            AddressBook
            ;
          inherit (darwin) libobjc;

          enableOfficialBranding = false;
          privacySupport = true;
        };

    firefox-history-merger = pkgs.callPackage ./pkgs/firefox-history-merger {
      inherit pins;
    };

    gcc-lua = pkgs.callPackage ./pkgs/gcc-lua { };

    json-yaml = pkgs.callPackage ./pkgs/json-yaml {
      inherit pins;
    };

    loudgain = pkgs.callPackage ./pkgs/loudgain {
      inherit pins;
    };

    sfutils = pkgs.callPackage ./pkgs/sfutils {
      inherit pins;
    };

    staticx = pkgs.python3Packages.callPackage ./pkgs/staticx {
      inherit pins;
      inherit (pkgs.writers) writeBash;
    };

    switch-dbibackend = pkgs.callPackage ./pkgs/switch-dbibackend {
      inherit pins;
    };

    systemd-lock-handler = pkgs.callPackage ./pkgs/systemd-lock-handler { };

    tagsistant = pkgs.callPackage ./pkgs/tagsistant {
      inherit pins;
    };

    tmm = pkgs.callPackage ./pkgs/tmm { };

    urxvt-config-reload = pkgs.callPackage ./pkgs/urxvt-config-reload {
      inherit (pkgs.perlPackages)
        AnyEvent
        LinuxFD
        CommonSense
        SubExporter
        DataOptList
        ParamsUtil
        SubInstall
        ;
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

    # Work-around NUR's eval test inexplicably failing on naersk, even though
    # running the eval test locally works fine =/
    uncheckedPkgs = {
      steamguard-cli = pkgs.callPackage ./pkgs/steamguard-cli {
        inherit naersk pins;
      };
    };

    yuescript = pkgs.callPackage ./pkgs/yuescript {
      inherit pins;
    };
  };
in
repo
