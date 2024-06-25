{ lib, fetchCrate, rustPlatform, pkg-config, udev }:
rustPlatform.buildRustPackage rec {
  pname = "elf2uf2-rs";
  version = "2.0.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "12winppjj4cq1f6v2xaxgn4yyxgyk92m3bhd1asffihf54xq4s3j";
  };

  cargoHash = "sha256-TBH3pLB6vQVGnfShLtFPNKjciuUIuTkvp3Gayzo+X9E=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];
}

