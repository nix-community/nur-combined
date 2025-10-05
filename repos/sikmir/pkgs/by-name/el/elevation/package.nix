{
  lib,
  fetchFromGitHub,
  python3Packages,
  click_6_7,
  gnumake,
  curl,
  unzip,
  gzip,
  gdal,
  testers,
  elevation,
}:

python3Packages.buildPythonApplication rec {
  pname = "elevation";
  version = "1.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bopen";
    repo = "elevation";
    tag = version;
    hash = "sha256-sZStJgToQtWYrBH1BjqxCUwQUT5dcAlyZwnb4aYga+4=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  dependencies = with python3Packages; [
    fasteners
    appdirs
    click_6_7
    setuptools
  ];

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "\"setuptools_scm_git_archive\"," ""
    substituteInPlace tests/test_datasource.py --replace-fail "/tmp" "./tmp"
    for f in elevation/datasource.* \
             elevation/util.py \
             tests/test_*.py; do
      substituteInPlace $f \
        --replace-warn "make " "${lib.getExe gnumake} " \
        --replace-warn "curl " "${lib.getExe curl} " \
        --replace-warn "gunzip " "gunzip.t " \
        --replace-warn "unzip " "${lib.getExe unzip} " \
        --replace-warn "gunzip.t " "${lib.getBin gzip}/bin/gunzip " \
        --replace-warn "gdal_translate " "${lib.getBin gdal}/bin/gdal_translate " \
        --replace-warn "gdalbuildvrt " "${lib.getBin gdal}/bin/gdalbuildvrt "
    done
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-mock
  ];

  postInstall = ''
    install -Dm644 elevation/datasource.mk -t $out/lib/${python3Packages.python.libPrefix}/site-packages/elevation
  '';

  passthru.tests.version = testers.testVersion { package = elevation; };

  meta = {
    description = "Python script to download global terrain digital elevation models, SRTM 30m DEM and SRTM 90m DEM";
    homepage = "http://elevation.bopen.eu/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "eio";
  };
}
