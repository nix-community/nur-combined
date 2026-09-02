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

  cargoHash = "sha256-2IaxrLFy7cf4NX0ULbQxCD7g4hMHHnMEOFZi3NkFGFM=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
  ];
})
