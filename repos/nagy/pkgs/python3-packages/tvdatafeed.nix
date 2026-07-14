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
  version = "0-unstable-2024-05-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "demonarch";
    repo = "tvdatafeed";
    rev = "fd9eed69813e08c07e42ae45c3d9bbb6564bf045";
    hash = "sha256-uPWU5rm0afKIus6Jgnby0DmEZlctvgSwTIWHTi6tTf4=";
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
