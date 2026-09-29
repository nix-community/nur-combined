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
  version = "2026-09-30";
  src = fetchFromGitHub {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "6dc947cbb4673c0f3c6e1a3ab04a7e5dacb00b67";
    hash = "sha256-vnQHsV1BLZ/wLE+9U8rPI7FrQ0yQrC88AaGPP6/SzTg=";
  };
}
