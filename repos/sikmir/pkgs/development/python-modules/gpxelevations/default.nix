{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchurl,
}:
let
  testdata = import ./testdata.nix { inherit fetchurl; };
in
python3Packages.buildPythonApplication rec {
  pname = "gpxelevations";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = "srtm.py";
    rev = "v${version}";
    hash = "sha256-/AGvFE74sJTnn70VklQp0MG+7dsooavAdSTyV2oJM+I=";
  };

  propagatedBuildInputs = with python3Packages; [
    requests
    gpxpy
  ];

  dontUseSetuptoolsCheck = true;

  checkPhase = ''
    mkdir -p tmp_home/.cache/srtm
    ${lib.concatMapStringsSep "\n" (hgt: ''
      cp ${hgt} tmp_home/.cache/srtm/${hgt.name}
    '') testdata}

    HOME=tmp_home ${python3Packages.python.interpreter} -m unittest test
  '';

  meta = {
    description = "Geo elevation data parser for \"The Shuttle Radar Topography Mission\" data";
    inherit (src.meta) homepage;
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
