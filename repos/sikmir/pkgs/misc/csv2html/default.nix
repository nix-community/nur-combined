{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "csv2html";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "dbohdan";
    repo = "csv2html";
    tag = "v${version}";
    hash = "sha256-H8nUwK72opUohBN2exZURRAPr1RXLa87exYaGigly0Q=";
  };

  cargoHash = "sha256-axvgAXstJU9J7fzez3qfEuxzPs6eCvlyjV8OsxBSg7A=";

  meta = {
    description = "Convert CSV files to HTML tables";
    homepage = "https://github.com/dbohdan/csv2html";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "csv2html";
  };
}
