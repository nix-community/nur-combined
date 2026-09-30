{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  cairo,
  fontconfig,
  pango,
  wayland,
  wayland-protocols,
  curl,
  libappindicator,
  gdk-pixbuf,
  openssl,
  json_c,
  glib,
  libexttextcat,
  wrapGAppsHook3,
}:

let
  generic = import ./generic.nix {
    inherit
      lib
      stdenv
      meson
      ninja
      pkg-config
      wayland-scanner
      cairo
      fontconfig
      pango
      wayland
      wayland-protocols
      curl
      libappindicator
      gdk-pixbuf
      openssl
      json_c
      glib
      libexttextcat
      wrapGAppsHook3
      ;
  };
in
generic {
  pname = "wshowlyrics-unstable";
  version = "2026-10-01";
  src = fetchFromGitHub {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "c74f6f30d82ddc3e1b95a0e286c19724350f3f53";
    hash = "sha256-NuU7lDCzV/gVMDXd4g22zlMRhERrAHMq+70oDBy9Cj4=";
  };
}
