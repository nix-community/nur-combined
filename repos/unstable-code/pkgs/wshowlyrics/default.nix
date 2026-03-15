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
  pname = "wshowlyrics";
  version = "0.10.0";
  src = fetchFromGitLab {
    owner = "wshowlyrics";
    repo = "wshowlyrics";
    rev = "v0.10.0";
    hash = "sha256-WNxEGMwWq1yR6YF+trp3rougR7hJI4oTQqOf2ZDfeZU=";
  };
}
