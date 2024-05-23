{ fetchFromGitHub
, gitUpdater
, lib
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "dmarc-report-notifier";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "AndrewKvalheim";
    repo = "dmarc-report-notifier";
    rev = "v${version}";
    hash = "sha256-7qb1UGkJZyNSMMGeUQcWgdQ0Dvm+Oew5AEjTuUADEEc=";
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
  };
}
