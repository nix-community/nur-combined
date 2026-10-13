{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage rec {
  pname = "krypton-cli";
  version = "0.4.2";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-na5hAcGylU7BSMkM/Z3jgSr+PYn05r7EeIkD3Ye7kKQ=";
  };

  cargoHash = "sha256-ZMXK033aubg34EiUWJPN17JA/jjNL29cBuAmiuo0LP8=";  

  meta = {
    description = "Command-line interface for the Krypton encryption library";
    homepage = "https://github.com/KryptonOSS/krypton-cli";
    license = lib.licenses.asl20;
    mainProgram = "krypton";
  };
}

