{
  rustPlatform,
  source,
}:
rustPlatform.buildRustPackage rec {
  pname = "kanata-vk-agent";
  cargoLock.lockFile = ./Cargo.lock;
  inherit (source) src version;
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';
}
