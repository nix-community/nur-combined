{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  cadabra2 = pkgs.callPackage ./pkgs/cadabra2 { };
  worksnaps-client = pkgs.callPackage ./pkgs/worksnaps-client { };
  mathics = pkgs.callPackage ./pkgs/mathics { };
  minimal-sddm-theme = pkgs.callPackage ./pkgs/minimal-sddm-theme { };
  _31key = pkgs.callPackage ./pkgs/31key { };
  mimi = pkgs.callPackage ./pkgs/mimi { };
  quake3-data = pkgs.callPackage ./pkgs/quake3-data { };
  deadbeef-waveform-seekbar-plugin =
    pkgs.callPackage ./pkgs/deadbeef-waveform-seekbar-plugin { };
  augr = pkgs.callPackage ./pkgs/augr { };
  rosie = pkgs.luaPackages.callPackage ./pkgs/rosie { };
  pcem = pkgs.callPackage ./pkgs/pcem { };
  ciao = pkgs.callPackage ./pkgs/ciao { };
  v4l2loopback-dc = pkgs.linuxPackages.callPackage ./pkgs/v4l2loopback-dc { };
  carla = pkgs.qt5.callPackage ./pkgs/carla { };
  libcyaml = pkgs.callPackage ./pkgs/libcyaml { };
  reproc = pkgs.callPackage ./pkgs/reproc { };
  libaudec = pkgs.callPackage ./pkgs/libaudec { };
}
