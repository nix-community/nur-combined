# This file describes your repository contents.  It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{  
  pkgs ? import (builtins.fetchTarball {
    # Descriptive name to make the store path easier to identify
    name = "nixpkgs-20.08.20";
    # Commit hash for nixos-unstable as of 2018-09-12
    url = "https://github.com/nixos/nixpkgs/archive/c59ea8b8a0e7f927e7291c14ea6cd1bd3a16ff38.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "1ak7jqx94fjhc68xh1lh35kh3w3ndbadprrb762qgvcfb8351x8v";
  }) {}
}:

let
  python37-importlib-metadata_1_7 = pkgs.python37.override {
    packageOverrides = self: super: {
      importlib-metadata = super.importlib-metadata.overrideAttrs (old: {
        version = "1.7.0";
        src = super.fetchPypi {
          pname = "importlib_metadata";
          version = "1.7.0";
          sha256 = "10vz0ydrzspdhdbxrzwr9vhs693hzh4ff71lnqsifvdzvf66bfwh";
        };
      });
    };
  };
in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  
  anystyle-cli = pkgs.callPackage ./pkgs/anystyle-cli { };
  argparse = pkgs.callPackage ./pkgs/argparse { };
  baobab = pkgs.callPackage ./pkgs/baobab { };
  bomber = pkgs.kdeApplications.callPackage ./pkgs/Bomber { };
  cargo-sort-ck = with pkgs.rustPlatform; pkgs.callPackage ./pkgs/cargo-sort-ck {
    inherit buildRustPackage;
  };
  compton = pkgs.callPackage ./pkgs/Compton { };
  controls-for-fake = pkgs.libsForQt5.callPackage ./pkgs/ControlsForFake  {
    inherit libfake;
    FakeMicWavPlayer = fake-mic-wav-player;
  };
  day-night-plasma-wallpapers = with pkgs.python3Packages; pkgs.callPackage ./pkgs/day-night-plasma-wallpapers { 
    dbus-python = dbus-python;
  };
  debtcollector = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/debtcollector { 
    inherit buildPythonPackage fetchPypi pbr six wrapt;
  };
  fake-mic-wav-player = pkgs.libsForQt5.callPackage ./pkgs/FakeMicWavPlayer {
    inherit libfake argparse;
  };
  haste-client = pkgs.callPackage ./pkgs/haste-client { };
  inkscape = pkgs.callPackage ./pkgs/inkscape-1.0 { 
    lcms = pkgs.lcms2;
  };
  juk = pkgs.kdeApplications.callPackage ./pkgs/Juk { };
  kapptemplate = pkgs.kdeApplications.callPackage ./pkgs/KAppTemplate { };
  kbreakout = pkgs.kdeApplications.callPackage ./pkgs/KBreakOut { };
  keysmith = pkgs.kdeApplications.callPackage ./pkgs/keysmith { };
  keystoneauth1 = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/keystoneauth1 { 
    inherit
      buildPythonPackage
      fetchPypi
      iso8601
      os-service-types
      pbr
      requests
      stevedore;
  };
  killbots = pkgs.kdeApplications.callPackage ./pkgs/Killbots { };
  kirigami-gallery = pkgs.kdeApplications.callPackage ./pkgs/KirigamiGallery { };
  ksmoothdock = pkgs.libsForQt5.callPackage ./pkgs/ksmoothdock { };
  libfake = pkgs.callPackage ./pkgs/FakeLib { };
  lokalize = pkgs.libsForQt5.callPackage ./pkgs/Lokalize { };
  merge-keepass = with pkgs.python3Packages; pkgs.callPackage ./pkgs/merge-keepass { 
    inherit buildPythonPackage pykeepass click pytest;
  };
  ncgopher = pkgs.callPackage ./pkgs/ncgopher { };
  numworks-udev-rules = pkgs.callPackage ./pkgs/numworks-udev-rules { };
  oslo-config = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/oslo-config { 
    inherit
      buildPythonPackage
      debtcollector
      fetchPypi
      importlib-metadata
      netaddr
      oslo-i18n
      pbr
      pyyaml
      requests
      rfc3986
      stevedore;
  };
  oslo-i18n = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/oslo-i18n { 
    inherit buildPythonPackage fetchPypi pbr six;
  };
  oslo-serialization = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/oslo-serialization { 
    inherit 
      buildPythonPackage
      fetchPypi
      msgpack
      oslo-utils
      pbr
      pytz;
  };
  oslo-utils = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/oslo-utils { 
    inherit 
      buildPythonPackage
      debtcollector
      fetchPypi 
      iso8601
      netaddr
      netifaces
      oslo-i18n
      packaging
      pbr
      pytz;
  };
  os-service-types = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/os-service-types { 
    inherit buildPythonPackage fetchPypi pbr six;
  };
  parallel-ssh = with pkgs.python3Packages; pkgs.callPackage ./pkgs/parallel-ssh {
    inherit buildPythonPackage setuptools fetchPypi paramiko gevent ssh2-python;
  };
  python-iconf = with pkgs.python3Packages; pkgs.callPackage ./pkgs/python-iconf {
    inherit buildPythonPackage fetchPypi pytest;
  };
  python-keystoneclient = with python37-importlib-metadata_1_7.pkgs; pkgs.callPackage ./pkgs/python-keystoneclient { 
    inherit
      buildPythonPackage
      fetchPypi
      keystoneauth1
      oslo-config
      oslo-i18n
      oslo-serialization
      pbr;
  };
  qtile = pkgs.callPackage ./pkgs/qtile { };
  rofi = pkgs.callPackage ./pkgs/rofi { };
  semantik = pkgs.libsForQt5.callPackage ./pkgs/semantik { };
  scripts = with pkgs.python3Packages; pkgs.callPackage ./pkgs/Scripts {
    eom = pkgs.mate.eom;
    inherit sync-database buildPythonPackage parallel-ssh merge-keepass;
  };
  slick-greeter = with pkgs.gnome3; pkgs.callPackage ./pkgs/slick-greeter {
    inherit gnome-common gtk slick-greeter;
  };
  spectacle-clipboard = pkgs.libsForQt5.callPackage ./pkgs/spectacle-clipboard { };
  ssh2-python = with pkgs.python3Packages; pkgs.callPackage ./pkgs/ssh2-python {
    inherit buildPythonPackage fetchPypi cython setuptools pytest;
  };
  super-tux-kart = pkgs.callPackage ./pkgs/SuperTuxKart {
    inherit wiiuse;
  };
  sync-database = with pkgs.python3Packages; pkgs.callPackage ./pkgs/sync-database {
    inherit buildPythonPackage parallel-ssh merge-keepass pykeepass;
  };
  vokoscreen-ng = with pkgs; libsForQt5.callPackage ./pkgs/vokoscreenNG {
    gstreamer = gst_all_1.gstreamer;
    gst-plugins-base = gst_all_1.gst-plugins-base;
    gst-plugins-good = gst_all_1.gst-plugins-good;
    gst-plugins-bad = gst_all_1.gst-plugins-bad;
    gst-plugins-ugly = gst_all_1.gst-plugins-ugly;
  };
  wiiuse = pkgs.callPackage ./pkgs/WiiUse { };

}

