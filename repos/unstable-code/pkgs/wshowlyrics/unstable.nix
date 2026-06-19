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
  version = "2026-06-20";
  src = fetchFromGitLab {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "85336ede2630b18a6697883cf57e1f2c2a218ee2";
    hash = "sha256-qdpMvfaYyckJdNOSNidtq7On9bp/6o2qTQH6uRavCJk=";
  };
}
