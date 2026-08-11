{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, poetry-core
}:

buildPythonPackage rec {
  pname = "codefind";
  version = "0.1.6";
  pyproject = true;

  src =
  if true then
  fetchurl {
    url = "https://github.com/breuleux/codefind/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-OlPLhPwGG1eZ1dxU2EFlEP5TLUYSdnGjOdbV2ZaKC7c=";
  }
  else
  # error
  fetchFromGitHub {
    owner = "breuleux";
    repo = "codefind";
    rev = "v${version}";
    hash = "sha256-jSAOlxHpi9hjRJjfj9lBpbgyEdiBCI7vVZ/RXspPbgc=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  pythonImportsCheck = [ "codefind" ];

  meta = with lib; {
    description = "Find code objects and their referents";
    homepage = "https://github.com/breuleux/codefind";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
