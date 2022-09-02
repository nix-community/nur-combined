{ lib, stdenv, fetchFromGitHub, python3Packages, smopy }:

python3Packages.buildPythonApplication rec {
  pname = "trackanimation";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "JoanMartin";
    repo = "trackanimation";
    rev = "v${version}";
    hash = "sha256-fLubRKq+3wQh16xSdqJmNMy4zw83RiSQj8C6jNV4fV8=";
  };

  propagatedBuildInputs = with python3Packages; [
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

  meta = with lib; {
    description = "GPS Track Animation Library";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
