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
  version = "2026-10-02";
  src = fetchFromGitHub {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "3319c6eaa7bf3d69abc258b0fed2605499b9103f";
    hash = "sha256-0CpNGOAWTHLvhzNbj3INZgmQ9XICczcaDq7GQsYvjGw=";
  };
}
