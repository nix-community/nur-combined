{sources, rustPlatform, fetchzip, lib}:
let
  inherit (sources) HVM;
in
rustPlatform.buildRustPackage {
  name = "HVM";
  src = fetchzip { inherit (HVM) url sha256; };
  cargoSha256 = "zy8Yvay5INBNnIOwckrqMvL2kT73GuS7gSUT4K+pzkc=";
  doCheck = false; # I'm sure it'll work out fiine
  meta = {
    description = "High-level virtual machine. Evaluates based on a fancy version of term rewriting, but in parralel";
    homepage = "https://github.com/Kindelia/HVM";
    license = lib.licenses.mit;
  };
}
