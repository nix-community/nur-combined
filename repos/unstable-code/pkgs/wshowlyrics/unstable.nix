{
  lib,
  stdenv,
  fetchFromGitLab,
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
  version = "2026-07-02";
  src = fetchFromGitLab {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "0a4f6e8f90eb99d7ee42661c03c844485ba0103f";
    hash = "sha256-juj+tgJr8klgT9fQhNUNIlXcW7QWbQQofYQMpmke588=";
  };
}
