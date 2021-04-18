{ fetchFromGitHub, lib, rustPlatform, }:

rustPlatform.buildRustPackage rec {
  pname = "uwuify";
  version = "0.2.2";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  cargoSha256 = "sha256-1BoB7K/dWy3AbogvHIDLrdPD7K54EISvn4RVU5RLTi4=";

  meta = with lib; {
    description = "fastest text uwuifier in the west";
    homepage = "https://github.com/Daniel-Liu-c0deb0t/uwu";
    license = licenses.mit;
  };
}
