{
  lib, makeRustPlatform, rust-bin,
  git,
  ...
}:
let
  pname = "mergiraf";
  version = "0.4.0";
  src = builtins.fetchGit {
    url = "https://codeberg.org/mergiraf/mergiraf.git";
    ref = "v${version}";
    allRefs = true;
    rev = "08cefbaa8bda56aa901d939f80a517d03e0fbb7f";
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
    # outputHashes = {
    # };
  };
  nativeBuildInputs = [ git ];
  meta = with lib; {
    description = "A syntax-aware git merge driver for a growing collection of programming languages and file formats.";
    homepage = "https://mergiraf.org";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
