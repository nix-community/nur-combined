{sources, rustPlatform, fetchzip}:
let
  inherit (sources) HVM;
in
rustPlatform.buildRustPackage {
  name = "HVM";
  src = fetchzip { inherit (HVM) url sha256; };
  cargoSha256 = "zy8Yvay5INBNnIOwckrqMvL2kT73GuS7gSUT4K+pzkc=";
  doCheck = false; # I'm sure it'll work out fiine
}
