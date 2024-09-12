{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  setuptools-scm,
  grpcio,
  # nix-update-script,
}:

buildPythonPackage rec {
  pname = "cs3apis";
  version = "0.1.dev105";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-adtljTXOjNjySHP/AQhDhnB/v4jPzy/LSkccTyauV/U=";
  };

  nativeBuildInputs = [
    setuptools-scm
    setuptools
  ];

  propagatedBuildInputs = [ grpcio ];

  # TODO: fix version detection for v2
  # passthru.updateScript = nix-update-script { };
  passthru.skipBulkUpdate = true;

  meta = with lib; {
    homepage = "https://github.com/cs3org/python-cs3apis/";
    description = "Official Python CS3APIS";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
