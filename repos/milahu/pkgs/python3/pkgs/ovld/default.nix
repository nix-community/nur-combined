{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, poetry-core
}:

buildPythonPackage rec {
  pname = "ovld";
  version = "0.3.5";
  pyproject = true;

  src =
  if true then
  fetchurl {
    url = "https://github.com/breuleux/ovld/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-B0PGCMQX2VzH0kIwMqGKG5wkvMuEShllKMFeIhxfU7U=";
  }
  else
  # error
  fetchFromGitHub {
    owner = "breuleux";
    repo = "ovld";
    rev = "v${version}";
    hash = "sha256-2s24I6CMldGJjneRFYuHTUAjdd+q//ABWiS8vR9pW1s=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  pythonImportsCheck = [ "ovld" ];

  meta = with lib; {
    description = "Advanced multiple dispatch for Python functions";
    homepage = "https://github.com/breuleux/ovld";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
