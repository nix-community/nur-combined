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
  version = "2026-10-22";
  src = fetchFromGitHub {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "7d8390962c7c9e8bd1d7bf852b9c2efb7b0a0368";
    hash = "sha256-EcdIHMTTT+CIDJyoPh3u+9RZNdQ6q5Ubcp0+kp6T5gE=";
  };
}
