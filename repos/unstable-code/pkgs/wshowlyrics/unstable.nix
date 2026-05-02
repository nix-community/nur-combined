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
  version = "2026-05-03";
  src = fetchFromGitLab {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "2842e39087760d01985188fda64faed602607088";
    hash = "sha256-GwYoEmUeZFG83dKOJkOb9B1ODf5IaG1CHKAsVAglsGM=";
  };
}
