{ pkgs, stdenv }:

with pkgs.python312Packages;
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
    rev = "a04dbbc640e39cd64bb785c2b0783bb7d99bbb29";
    sha256 = "sha256-qh3zn5dxzP8/0QL0AdLdLlJ5UWAjk6R49mt3CigfLkc=";
  };
}
