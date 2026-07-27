{
  sources,
  fetchFromGitHub,

  lib,
  python3Packages,
}:
let
  wstd2daisy = python3Packages.buildPythonPackage {
    inherit (sources.wstd2daisy) pname src;
    version = sources.wstd2daisy.date;

    pyproject = true;

    build-system = with python3Packages; [
      setuptools-scm
    ];

    dependencies = with python3Packages; [
      jinja2
    ];
  };
in
python3Packages.buildPythonPackage {
  inherit (sources.hvcc) pname src;
  version = lib.removePrefix "v" sources.hvcc.version;

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
}
