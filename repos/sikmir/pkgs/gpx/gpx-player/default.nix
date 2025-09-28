{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "gpx-player";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kirienko";
    repo = "gpx-player";
    tag = "v${version}";
    hash = "sha256-vLY+uQvIT9WpbtU1lxRzEx/taxi3q6y7AITr+NJ1nW0=";
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
}
