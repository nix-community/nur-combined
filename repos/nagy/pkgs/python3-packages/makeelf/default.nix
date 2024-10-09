{
  lib,
  buildPythonPackage,
  setuptools,
  wheel,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "makeelf";
  version = "0.3.4";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nYuM8WsAEW6nLZb5+VYcD5YL7ceOaHQ+JFnx8dceBXI=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "makeelf" ];

  meta = {
    description = "ELF reader-writer library";
    homepage = "https://pypi.org/project/makeelf/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
