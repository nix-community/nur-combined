{ lib, fetchFromGitHub, rustPlatform, fuse, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "save3ds";
  version = "dev-2023-03-28";

  src = fetchFromGitHub {
    owner = "wwylele";
    repo = pname;
    rev = "c42ef5356bcac92e679ebc95e2d4c263cda0a2f1";
    hash = "sha256-fmwVcGOXq4BvszEVboyon5y3xR1yEIwnDdCzCR7f3M8=";
  };

  cargoHash = "sha256-1BgEb02j6yC94sy8Io+RT6dfux8vvCu03pI2x1yUHYk=";

  buildInputs = [ fuse ];
  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Extract/Import/FUSE for 3DS save/extdata/database.";
    homepage = "https://github.com/wwylele/save3ds";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "save3ds_fuse";
  };
}
