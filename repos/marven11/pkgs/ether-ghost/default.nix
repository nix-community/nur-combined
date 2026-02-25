{ pkgs, stdenv }:

with pkgs.python3Packages;
buildPythonPackage rec {
  pname = "ether-ghost";
  version = "0.2.0";
  pyproject = true;

  propagatedBuildInputs = [ build packaging poetry-core ];
  dependencies = [
    pydantic
    fastapi
    requests
    pycryptodome
    sqlalchemy
    uvicorn
    sqlalchemy-utils
    httpx
    socksio
    chardet
    python-multipart
  ];

  src = pkgs.fetchFromGitHub {
    owner = "Marven11";
    repo = "EtherGhost";
    rev = "42f1f660035bfab48b6e5dc16dd7b5daaed8e2d0";
    sha256 = "sha256-0K84SrlCHNXphzKmttlO1p0kpHAbWyZZDmoIq8wJX4I=";
  };
}
