{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # dependencies
  requests,
}:
buildPythonPackage rec {
  pname = "srtm.py";
  version = "0.3.7";

  # testing require a RW filesystem
  doCheck = false;

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/AGvFE74sJTnn70VklQp0MG+7dsooavAdSTyV2oJM+I=";
  };

  propagatedBuildInputs = [
    requests
  ];

  meta = with lib; {
    changelog = "https://github.com/tkrajina/srtm.py/blob/v${version}/CHANGELOG.md";
    description = "Geo elevation data parser for \"The Shuttle Radar Topography Mission\" data";
    homepage = "https://github.com/tkrajina/srtm.py";
    license = licenses.mit;
  };
}
