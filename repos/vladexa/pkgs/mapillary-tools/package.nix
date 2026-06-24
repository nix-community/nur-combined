{
  fetchFromGitHub,
  ffmpeg,
  lib,
  python3Packages,
  ...
}:

python3Packages.buildPythonApplication rec {
  pname = "mapillary-tools";
  version = "0.14.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mapillary";
    repo = "mapillary_tools";
    tag = "v${version}";
    hash = "sha256-V9Ear1yYy+yf0pdICDylBAA+hCz9aWDuPuIqRV4qEUQ=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    appdirs
    construct
    exifread
    gpxpy
    humanize
    jsonschema
    piexif
    pynmea2
    pysocks
    requests
    tqdm
    typing-extensions
  ];

  pythonRelaxDeps = [ "jsonschema" ];

  propogatedBuildInputs = [ ffmpeg ];

  pythonImportsCheck = [ "mapillary_tools" ];

  meta = {
    description = "Mapillary image and video import pipeline";
    homepage = "https://github.com/mapillary/mapillary_tools";
    changelog = "https://github.com/mapillary/mapillary_tools/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    mainProgram = "mapillary_tools";
  };
}
