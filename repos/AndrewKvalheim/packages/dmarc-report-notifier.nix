{ fetchFromGitea
, gitUpdater
, lib
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "dmarc-report-notifier";
  version = "1.1.8";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "dmarc-report-notifier";
    rev = "refs/tags/v${version}";
    hash = "sha256-xoZDwAxzVkqmuR9JwyguL+HSahbbockikoDXZUle4Oo=";
  };

  format = "pyproject";

  nativeBuildInputs = with python3Packages; [
    poetry-core
  ];

  propagatedBuildInputs = with python3Packages; [
    jinja2
    jinja2_pluralize
    matrix-nio
    parsedmarc
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Headless periodic DMARC report handler";
    homepage = "https://codeberg.org/AndrewKvalheim/dmarc-report-notifier";
    license = lib.licenses.gpl3;
    mainProgram = "dmarc-report-notifier";
  };
}
