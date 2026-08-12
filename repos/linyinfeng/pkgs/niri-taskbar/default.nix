{
  sources,
  lib,
  rustc,
  rustPlatform,

  pkg-config,
  gtk3,
}:

rustPlatform.buildRustPackage {
  inherit (sources.niri-taskbar) pname version src;
  cargoLock = sources.niri-taskbar.cargoLock."Cargo.lock";

  postPatch = ''
    sed --in-place 's/rust-version = .*//' Cargo.toml
  '';

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    gtk3
  ];

  meta = {
    description = "Niri taskbar module for Waybar";
    homepage = "https://github.com/LawnGnome/niri-taskbar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yinfeng ];
    broken = !(lib.versionAtLeast rustc.version "1.85");
  };
}
