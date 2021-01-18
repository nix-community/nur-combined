{ lib, python3Packages, mercantile, pymbtiles, sources }:

python3Packages.buildPythonApplication {
  pname = "garmin-uploader-unstable";
  version = lib.substring 0 10 sources.gupload.date;

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
