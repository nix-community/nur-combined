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

  cargoHash = "sha256-utwCam4pskImRTGqP3T37T+LqOVkX+eiUNhw+X/I0fw=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
  ];
})
