{ fetchFromGitHub, lib, rustPlatform, }:

rustPlatform.buildRustPackage rec {
  pname = "uwuify";
  version = "0.1.0";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  cargoSha256 = "043glp98jhaapxa19k2kx1hawqpcqiz4g5sw4b82lj2vzhfb2bxx";

  meta = with lib; {
    description = "fastest text uwuifier in the west";
    homepage = "https://github.com/Daniel-Liu-c0deb0t/uwu";
    license = licenses.mit;
  };
}
