{
  lib, makeRustPlatform, fetchgit, rust-bin,
}:
let
  pname = "rzup";
  version = "2.0.2";
  src = fetchgit {
    url = "https://github.com/risc0/risc0.git";
    rev = "refs/tags/v${version}";
    hash = "sha256-IEqpkcrfd5MAiK1KLSN3Pkmcqml21+QZONknJQsEaJc=";
  };

  rustPlatform = makeRustPlatform {
    cargo = rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
    rustc = rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    allowBuiltinFetchGit = true;
  };
  cargoBuildFlags = ["-p rzup"];

  meta = with lib; {
    description = "The RISC Zero version management library and CLI";
    homepage = "https://github.com/risc0/risc0";
    license = licenses.apsl20;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
