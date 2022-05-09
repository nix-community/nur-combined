{ lib
, buildPythonPackage
, fetchFromGitHub
, osmnx
, tabulate
}:

buildPythonPackage rec {
  pname = "prettymaps";
  version = "2022-01-07";

  src = fetchFromGitHub {
    owner = "marceloprates";
    repo = "prettymaps";
    rev = "72fd33ce5f075020ea272e80df906c64c53d4d93";
    sha256 = "OpXwLdBGf8S86FZX2Hk0uuD7NFIv/e2hdmDnoAN66NQ=";
  };

  postPatch = ''
    substituteInPlace requirements.txt --replace osmnx==1.0.1 osmnx>=1.0.1
  '';

  doCheck = false;

  propagatedBuildInputs = [
    osmnx
    tabulate
  ];

  meta = with lib; {
    description = "A small set of Python functions to draw pretty maps from OpenStreetMap data";
    license = licenses.agpl3;
  };
}
