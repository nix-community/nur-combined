{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  requests,
  # FIXME error: attribute 'browsermob-proxy' missing
  # pkgs,
  pkgs-browsermob-proxy,
}:

buildPythonPackage rec {
  pname = "browsermob-proxy";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AutomatedTester";
    repo = "browsermob-proxy-py";
    rev = "v${version}";
    hash = "sha256-JQ7f8/Xz8A4PmhV3fsRqBJL9slBWG9iwziMuhlSHEBI=";
  };

  # FIXME error: attribute 'browsermob-proxy' missing
  # pkgs.browsermob-proxy
  postPatch = ''
    substituteInPlace browsermobproxy/server.py \
      --replace \
        "path='browsermob-proxy'" \
        "path='${pkgs-browsermob-proxy}/bin/browsermob-proxy'"
  '';

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    requests
  ];

  pythonImportsCheck = [
    "browsermobproxy"
  ];

  meta = {
    description = "A python wrapper for Browsermob Proxy";
    homepage = "https://github.com/AutomatedTester/browsermob-proxy-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
