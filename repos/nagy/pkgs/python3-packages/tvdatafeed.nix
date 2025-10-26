{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  wheel,
  pandas,
  requests,
  websocket-client,
}:

buildPythonPackage {
  pname = "tvdatafeed";
  version = "0-unstable-2025-10-06";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "tvdatafeed";
    rev = "9a142d9ff3a5f8c6256f295db24128c063ca405e";
    hash = "sha256-3wFaVwkvLS9iV9uz44/x1fc38XbwRdRFnUCEANOBF0k=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    pandas
    requests
    setuptools
    websocket-client
  ];

  pythonImportsCheck = [
    "tvDatafeed"
  ];

  meta = {
    description = "Simple TradingView historical Data Downloader";
    homepage = "https://github.com/demonarch/tvdatafeed/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "tvdatafeed";
  };
}
