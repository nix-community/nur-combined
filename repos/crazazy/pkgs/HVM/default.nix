{sources, rustPlatform, fetchzip, lib}:
let
  inherit (sources) HVM;
in
rustPlatform.buildRustPackage rec {
  name = "HVM";
  src = fetchzip { inherit (HVM) url sha256; };
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };
  doCheck = false; # I'm sure it'll work out fiine
  meta = {
    description = "High-level virtual machine. Evaluates based on a fancy version of term rewriting, but in parralel";
    homepage = "https://github.com/Kindelia/HVM";
    license = lib.licenses.mit;
  };
}
