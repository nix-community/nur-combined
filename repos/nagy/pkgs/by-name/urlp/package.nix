{ lib, rustPlatform, fetchFromGitHub, fetchpatch }:

rustPlatform.buildRustPackage rec {
  pname = "urlp";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "clayallsopp";
    repo = "urlp";
    rev = version;
    hash = "sha256-OsK24F+kjvrMC1tO3AOfgGm8/WczrdLj0kOSb+KiM6Y=";
  };

  patches = [
    # fix build
    (fetchpatch {
      url = "https://github.com/clayallsopp/urlp/pull/2.patch";
      hash = "sha256-JAXCrQ9NJi2V2t5MaMCCKiB+bLqgrnkAdjgTvG/ZC1w=";
    })
  ];

  cargoLock = { lockFile = ./Cargo.lock; };

  postPatch = ''
    ln -fs ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "A command-line URL parser, written in Rust";
    homepage = "https://github.com/clayallsopp/urlp";
    maintainers = with maintainers; [ nagy ];
  };
}
