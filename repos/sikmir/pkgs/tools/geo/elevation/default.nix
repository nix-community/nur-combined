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

python3Packages.buildPythonApplication {
  pname = "elevation-unstable";
  version = lib.substring 0 10 sources.elevation.date;

  src = sources.elevation;

  propagatedBuildInputs = with python3Packages; [ fasteners appdirs click setuptools ];

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

  checkInputs = with python3Packages; [ pytestCheckHook pytest-mock ];

  meta = with lib; {
    inherit (sources.elevation) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
