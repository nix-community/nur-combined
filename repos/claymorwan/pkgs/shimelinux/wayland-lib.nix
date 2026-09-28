{
  # lib,
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

  cargoHash = "sha256-2Lv2vNslHFqc327OAgjJFoFAITXVah7g/WNvky771ls=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
  ];
})
