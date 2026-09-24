{
  pipewire,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  name = "sane-sysvol";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];
  buildInputs = [
    pipewire
  ];
}
