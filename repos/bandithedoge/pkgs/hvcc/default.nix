{
  pkgs,
  sources,
  pythonPkgs ? pkgs.python3Packages,
  ...
}: let
  wstd2daisy = pythonPkgs.buildPythonPackage {
    inherit (sources.wstd2daisy) pname src;
    version = sources.wstd2daisy.date;

    pyproject = true;

    build-system = with pythonPkgs; [
      setuptools-scm
    ];

    dependencies = with pythonPkgs; [
      jinja2
    ];
  };
in
  pythonPkgs.buildPythonPackage {
    inherit (sources.hvcc) pname version src;

    pyproject = true;

    dependencies = with pythonPkgs; [
      importlib-resources
      poetry-core
      pydantic
      wstd2daisy
    ];

    doCheck = false;

    meta = with pkgs.lib; {
      description = "The heavy hvcc compiler for Pure Data patches. Updated to python3 and additional generators ";
      homepage = "https://wasted-audio.github.io/hvcc/";
      license = licenses.gpl3;
      platform = platforms.unix;
    };
  }
