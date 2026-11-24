{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage rec {
  pname = "keres-cli";
  version = "0.7.0";

  src = fetchCrate {
    inherit pname version;
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;  

  meta = {
    description = "Command-line interface for the Keres";
    homepage = "https://github.com/keres-rs/keres-cli";
    license = lib.licenses.asl20;
    mainProgram = "keres";
  };
}

