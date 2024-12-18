{
  fetchFromGitHub,
  rustPlatform,
  callPackage,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "vl-convert";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "vega";
    repo = "vl-convert";
    rev = "v${version}";
    hash = "sha256-dmfY05i5nCiM2felvBcSuVyY8G70HhpJP3KrRGQ7wq8=";
  };

  buildAndTestSubdir = "vl-convert";

  cargoHash = "sha256-23t2aauiLBiFY6zENrqHJNr57H43H2/TtLLajqCvtXY=";

  RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix {};

  meta = {
    description = "Utilities for converting Vega-Lite specs from the command line and Python";
    homepage = "https://github.com/vega/vl-convert";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [renesat];
  };
}
