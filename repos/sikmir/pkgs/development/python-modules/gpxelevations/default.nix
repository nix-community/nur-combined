{ lib, python3Packages, fetchurl, sources }:
let
  pname = "gpxelevations";
  date = lib.substring 0 10 sources.gpxelevations.date;
  version = "unstable-" + date;

  testdata = import ./testdata.nix { inherit fetchurl; };
in
python3Packages.buildPythonApplication {
  inherit pname version;
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
