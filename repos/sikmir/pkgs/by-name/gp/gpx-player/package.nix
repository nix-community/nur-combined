{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gpx-player";
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kirienko";
    repo = "gpx-player";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2teWg6DKO05T1GZV2N5PIyItRhCXPJBXbBOBmCWvyi8=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    folium
    jinja2
    matplotlib
    pytz
    lxml
    numpy
    gpxpy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Visualise & animate GPX race tracks";
    homepage = "https://github.com/kirienko/gpx-player";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "gpx-player";
  };
})
