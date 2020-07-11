{ lib
, python3Packages
, click
, gnumake
, curl
, unzip
, gzip
, gdal
, sources
}:
let
  pname = "elevation";
  date = lib.substring 0 10 sources.elevation.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.elevation;

  propagatedBuildInputs = with python3Packages; [ fasteners future appdirs click ];

  postPatch = ''
    for f in elevation/datasource.* \
             elevation/util.py \
             tests/test_*.py; do
      substituteInPlace $f \
        --replace "make " "${lib.getBin gnumake}/bin/make " \
        --replace "curl " "${lib.getBin curl}/bin/curl " \
        --replace "gunzip " "gunzip.t " \
        --replace "unzip " "${lib.getBin unzip}/bin/unzip " \
        --replace "gunzip.t " "${lib.getBin gzip}/bin/gunzip " \
        --replace "gdal_translate " "${lib.getBin gdal}/bin/gdal_translate " \
        --replace "gdalbuildvrt " "${lib.getBin gdal}/bin/gdalbuildvrt "
    done
  '';

  checkInputs = with python3Packages; [ pytest pytest-mock ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.elevation) description homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
