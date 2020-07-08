{ lib
, buildPythonApplication
, fasteners
, future
, appdirs
, click
, gnumake
, curl
, unzip
, gzip
, gdal
, pytest
, pytest-mock
, sources
}:

buildPythonApplication {
  pname = "elevation";
  version = lib.substring 0 7 sources.elevation.rev;
  src = sources.elevation;

  propagatedBuildInputs = [ fasteners future appdirs click ];

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

  checkInputs = [ pytest pytest-mock ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.elevation) description homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
