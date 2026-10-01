{
  lib,
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

  cargoHash = "sha256-+/lKQOtRmA6NyGdYlKGa5A7qtOIrEkOobN6rylLWlac=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
  ];
})
