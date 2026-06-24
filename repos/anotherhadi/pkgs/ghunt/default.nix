{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  poetry-core,
  pythonRelaxDepsHook,
  alive-progress,
  autoslot,
  beautifulsoup4,
  beautifultable,
  dnspython,
  geopy,
  httpx,
  humanize,
  imagehash,
  inflection,
  jsonpickle,
  pillow,
  protobuf,
  python-dateutil,
  rich,
  rich-argparse,
  packaging,
}:
buildPythonApplication (finalAttrs: {
  pname = "ghunt";
  version = "2.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mxrch";
    repo = "ghunt";
    rev = "5ee893929c51c7a8a665b199bbae04ce85a662b4";
    hash = "sha256-pBH8Uhh+Yg9rrX8duEPLf/+JF5PR4I5zUhQ4EMiyk7A=";
  };

  pythonRelaxDeps = true;

  nativeBuildInputs = [
    poetry-core
    pythonRelaxDepsHook
  ];

  propagatedBuildInputs =
    [
      alive-progress
      autoslot
      beautifulsoup4
      beautifultable
      dnspython
      geopy
      httpx
      humanize
      imagehash
      inflection
      jsonpickle
      pillow
      protobuf
      python-dateutil
      rich
      rich-argparse
      packaging
    ]
    ++ httpx.optional-dependencies.http2;

  doCheck = false;

  pythonImportsCheck = [
    "ghunt"
  ];

  meta = {
    description = "Offensive Google framework";
    mainProgram = "ghunt";
    homepage = "https://github.com/mxrch/ghunt";
    changelog = "https://github.com/mxrch/GHunt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = [];
  };
})
