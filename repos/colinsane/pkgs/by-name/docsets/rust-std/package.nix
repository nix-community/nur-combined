{
  docsets,
  rustc,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "std";
  inherit (rustc) version;
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    substituteInPlace crates/*/Cargo.toml \
      --replace-fail 'version = "0.1.0"' 'version = "'"$version"'"'
  '';

  nativeBuildInputs = [ docsets.cargoDocsetHook ];
}
