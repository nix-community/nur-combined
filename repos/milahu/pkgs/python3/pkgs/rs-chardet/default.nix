# based on
# https://github.com/emattiza/rs_chardet/raw/main/flake.nix
# https://github.com/emattiza/rs_chardet/raw/main/nix/package.nix

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  stdenv,
  pythonOlder,
  rustPlatform,
  libiconv,
}:

buildPythonPackage rec {
  pname = "rs-chardet";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "emattiza";
    repo = "rs_chardet";
    rev = "v${version}";
    hash = "sha256-tCtRn13O1DoxtEwth7UU3vZaNNj9Fb5L1vXorMySbwA=";
  };

  format = "pyproject";
  disabled = pythonOlder "3.7";

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-IvGOCT4xFAMsB1qko16ZsxgzZD4ICV2IKnK1+CX2RsA=";
  };

  nativeBuildInputs = with rustPlatform; [ cargoSetupHook maturinBuildHook ];

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv ];

  pythonImportsCheck = [ "rs_chardet" ];

  meta = with lib; {
    description = "A python binding to chardetng";
    license = licenses.asl20;
    #maintainers = with maintainers; [ emattiza ];
    maintainers = with maintainers; [ ];
  };
}
