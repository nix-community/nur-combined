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
  extraRustcOpts = [ "-Znext-lockfile-bump" ];
  meta = {
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
