{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gpxchart";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = "gpxchart";
    tag = "v${version}";
    hash = "sha256-3HDj4k5mSUrJOxN2DrsHjMtX8PylxHExJeMc5CuaPP8=";
  };

  vendorHash = null;

  doCheck = false;

  meta = {
    description = "A command-line tool and library for elevation charts from GPX files";
    homepage = "https://github.com/tkrajina/gpxchart";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
