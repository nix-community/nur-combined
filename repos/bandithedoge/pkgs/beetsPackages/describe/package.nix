{
  sources,

  python3Packages,
  beets,
  lib,
}:
python3Packages.buildPythonApplication {
  inherit (sources.beets-describe) pname version src;

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    beets
  ];

  dependencies = with python3Packages; [
    termtables
    numpy
    pandas
    termplotlib
  ];

  nativeCheckInputs = with python3Packages; [
    pytest
    coverage
    mock
    six
    pyyaml
  ];

  meta = {
    description = "A beets plugin for obsessive-compulsive music geeks to describe what's in their library";
    homepage = "https://github.com/adamjakab/BeetsPluginDescribe";
    license = lib.licenses.mit;
    inherit (beets.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
