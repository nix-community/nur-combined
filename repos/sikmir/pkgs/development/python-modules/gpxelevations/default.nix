{ lib, python3Packages, fetchurl, sources }:
let
  testdata = import ./testdata.nix { inherit fetchurl; };
in
python3Packages.buildPythonApplication {
  pname = "gpxelevations-unstable";
  version = lib.substring 0 10 sources.gpxelevations.date;

  src = sources.gpxelevations;

  propagatedBuildInputs = with python3Packages; [ requests gpxpy ];

  postPatch = ''
    mkdir -p tmp_home/.cache/srtm
    ${lib.concatMapStringsSep "\n" (hgt: ''
      cp ${hgt} tmp_home/.cache/srtm/${hgt.name}
    '') testdata}
  '';

  checkPhase = ''
    HOME=tmp_home ${python3Packages.python.interpreter} -m unittest test
  '';

  meta = with lib; {
    inherit (sources.gpxelevations) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
