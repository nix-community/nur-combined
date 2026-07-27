{
  sources,

  python3Packages,
  beets,
  lib,
}:
python3Packages.buildPythonApplication {
  inherit (sources.beets-yearfixer) pname version src;

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    beets
  ];

  dependencies = with python3Packages; [
    requests
  ];

  nativeCheckInputs = with python3Packages; [
    pytest
    coverage
    mock
    six
    pyyaml
  ];

  meta = {
    description = "A beets plugin for obsessive-compulsive music geeks to fix missing album release date";
    homepage = "https://github.com/adamjakab/BeetsPluginYearFixer";
    license = lib.licenses.mit;
    inherit (beets.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
