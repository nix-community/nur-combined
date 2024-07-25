{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fuse3,
  macfuse-stubs,
  pkg-config,
}:

let
  fuse = if stdenv.isDarwin then macfuse-stubs else fuse3;
in
rustPlatform.buildRustPackage rec {
  pname = "ffs";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "mgree";
    repo = "ffs";
    rev = "v${version}";
    hash = "sha256-7hYH+utmAoWtV2xZLvSnE8779qKvzIJVJt9mNwH82sY=";
  };

  cargoHash = "sha256-otZIFcXvSXYdd23jlSlXn5ExoUhTBCRnnqhO4ksb3Pw=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ fuse ];

  doCheck = false;

  meta = {
    description = "the file filesystem";
    homepage = "https://github.com/mgree/ffs";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ffs";
  };
}
