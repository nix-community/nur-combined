{
  sources,

  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage {
  inherit (sources.termtables) pname version src;
  pyproject = true;

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  meta = {
    description = "Pretty tables in the terminal";
    homepage = "https://github.com/nschloe/termtables";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
