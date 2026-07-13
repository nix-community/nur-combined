{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "leaf";
  version = "1.22.2";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    rev = version;
    hash = "sha256-zpKKChKlKRwoPHfSNBHNuH11ZQRH5jQyhU9OeDckO1I=";
  };

  cargoHash = "sha256-PpbluFMNdfCF4onArZsmXtYSE2Fkd2n4WYCkPLDYkX8=";

  meta = {
    description = "Terminal Markdown previewer — GUI-like experience";
    homepage = "https://github.com/RivoLink/leaf";
    license = lib.licenses.mit;
    mainProgram = "leaf";
  };
}
