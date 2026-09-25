{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  aiohttp,
  websockets,
  orjson,
}:

buildPythonPackage rec {
  pname = "cdp-socket";
  version = "1.2.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ttlns";
    repo = "CDP-Socket";
    rev = "4813479d7b856c4a609aa19e6fea80ed9d425445";
    hash = "sha256-zemAwOv/ATfuq+zTvFQnCpJskfJzU17r6nPX0mw9zdU=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  # https://github.com/ttlns/CDP-Socket/blob/master/setup.py
  propagatedBuildInputs = [
    aiohttp
    websockets
    orjson
  ];

  pythonImportsCheck = [ "cdp_socket" ];

  meta = with lib; {
    description = "Socket for handling chrome-developer-protocol connections";
    homepage = "https://github.com/ttlns/CDP-Socket";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
