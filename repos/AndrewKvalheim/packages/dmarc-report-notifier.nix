{ fetchFromGitHub
, gitUpdater
, lib
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "dmarc-report-notifier";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "AndrewKvalheim";
    repo = "dmarc-report-notifier";
    rev = "v${version}";
    hash = "sha256-P+3V+VeWKQoT45j/Jt/smC+3Cr/IsGFp3FP2KD2hIi8=";
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
    homepage = "https://github.com/AndrewKvalheim/dmarc-report-notifier";
    license = lib.licenses.gpl3;
  };
}
