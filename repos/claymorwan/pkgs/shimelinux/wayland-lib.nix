{
  rustPlatform,
  pkg-config,
  libxkbcommon,
  callPackage,
}:

let
  shimelinux = callPackage ./default.nix { };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "${shimelinux.pname}-wayland-lib";
  inherit (shimelinux) version;

  src = "${shimelinux.src}/shimelinux_wayland";

  cargoHash = "sha256-GxCD1wYSqOeI7chIYcllWmLcG3k32eM3ZeGlbDhrCHc=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
  ];
})
