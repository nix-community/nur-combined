{ lib
, fetchFromGitHub
, python3Packages
, click
, gnumake
, curl
, unzip
, gzip
, gdal
, testers
, elevation
}:

python3Packages.buildPythonApplication rec {
  pname = "elevation";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "bopen";
    repo = "elevation";
    rev = version;
    hash = "sha256-sZStJgToQtWYrBH1BjqxCUwQUT5dcAlyZwnb4aYga+4=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

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

  postInstall = ''
    install -Dm644 elevation/datasource.mk -t $out/lib/${python3Packages.python.libPrefix}/site-packages/elevation
  '';

  passthru.tests.version = testers.testVersion {
    package = elevation;
  };

  meta = with lib; {
    description = "Python script to download global terrain digital elevation models, SRTM 30m DEM and SRTM 90m DEM";
    homepage = "http://elevation.bopen.eu/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "eio";
  };
}
