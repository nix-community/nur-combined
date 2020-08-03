{ lib, python3Packages, mercantile, pymbtiles, sources }:
let
  pname = "garmin-uploader";
  date = lib.substring 0 10 sources.gupload.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.gupload;

  propagatedBuildInputs = with python3Packages; [ requests ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = with lib; {
    inherit (sources.gupload) description homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
