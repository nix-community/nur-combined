{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  cachetools,
  crcmod,
}:

buildPythonPackage rec {
  pname = "python-ext4";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Eeems";
    repo = "python-ext4";
    rev = "v${version}";
    hash = "sha256-Y1wDcP787c38Y59kQZdbZhFSnYgaixW4B6wOkLK2Slw=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i 's/==.*//' requirements.txt
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    cachetools
    crcmod
  ];

  pythonImportsCheck = [
    "ext4"
  ];

  meta = {
    description = "Library for read only interactions with an ext4 filesystem";
    homepage = "https://github.com/Eeems/python-ext4";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
