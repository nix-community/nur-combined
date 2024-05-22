{ fetchCrate
, lib
, nix-update-script
, rustPlatform

  # Dependencies
, nasm
}:

rustPlatform.buildRustPackage rec {
  pname = "cavif";
  version = "1.5.4";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-2+pp5dCd64iJkoQ8NEARhlaih82BSnWBdQvBgjRFRmE=";
  };

  cargoHash = "sha256-fQG5BzHgueTLBAplLR/1X2/r88GpCoko0gFRf37Y2hI=";

  nativeBuildInputs = [ nasm ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AVIF image creator in pure Rust";
    homepage = "https://github.com/kornelski/cavif-rs";
    license = lib.licenses.bsd3;
  };
}
