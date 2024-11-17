{
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  name = "example-rust-pkg";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    # add extra inputs here ...
  ];
  buildInputs = [
    # add extra inputs here ...
  ];
}
