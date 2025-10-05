{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  smopy,
}:

python3Packages.buildPythonApplication rec {
  pname = "trackanimation";
  version = "1.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "JoanMartin";
    repo = "trackanimation";
    tag = "v${version}";
    hash = "sha256-fLubRKq+3wQh16xSdqJmNMy4zw83RiSQj8C6jNV4fV8=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    geopy
    gpxpy
    pillow
    matplotlib
    mplleaflet
    pandas
    tqdm
    smopy
  ];

  pythonImportsCheck = [ "trackanimation" ];

  meta = {
    description = "GPS Track Animation Library";
    homepage = "https://github.com/JoanMartin/trackanimation";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
