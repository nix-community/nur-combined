{
  fetchFromGitHub,
  lib,
  python3Packages,
}:
let
  wstd2daisy = python3Packages.buildPythonPackage {
    pname = "wstd2daisy";
    version = "0.5.3";
    src = fetchFromGitHub {
      owner = "Wasted-Audio";
      repo = "json2daisy";
      rev = "71e2982454d3410c5e4479c2d0dfa575a9826d17";
      hash = "sha256-1QKYx9gocAKKWCP9uEmuhtFWCptCd+vBlga5keBxkzY=";
    };

    pyproject = true;

    build-system = with python3Packages; [
      setuptools-scm
    ];

    dependencies = with python3Packages; [
      jinja2
    ];
  };
in
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "hvcc";
  version = "0.17.1";
  src = fetchFromGitHub {
    owner = "Wasted-Audio";
    repo = "hvcc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pPpZYxjSCXvJ4p+65Rj292BT1KYJYYEFSp4f/UBmUnY=";
  };

  pyproject = true;

  dependencies = with python3Packages; [
    arpeggio
    importlib-resources
    poetry-core
    pydantic
    pydantic-extra-types
    wstd2daisy
  ];

  doCheck = false;

  meta = {
    description = "The heavy hvcc compiler for Pure Data patches. Updated to python3 and additional generators ";
    homepage = "https://wasted-audio.github.io/hvcc/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "hvcc";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
