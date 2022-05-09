{ lib
, callPackage
, buildPythonPackage
, fetchFromGitHub
, geopandas
, osmnx
, shapely
, tabulate
}:

let
  descartes = callPackage
    ({ lib
    , buildPythonPackage
    , fetchFromGitHub
    , matplotlib
    , shapely
    }:

    buildPythonPackage rec {
      pname = "descartes";
      version = "1.1.0";

      src = fetchFromGitHub {
        owner = "benjimin";
        repo = pname;
        rev = "0842f2d21c4fff7f4a3fd91a194de6408842720d";
        sha256 = "BM+0vqSpHOxBDRID9M1up6dFyB1sgh36PiYE4oe6eIc=";
      };

      propagatedBuildInputs = [
        matplotlib
        shapely
      ];

      doCheck = false;
    }) { };
in buildPythonPackage rec {
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

  doCheck = true;

  propagatedBuildInputs = [
    descartes
    geopandas
    osmnx
    tabulate
  ];

  meta = with lib; {
    description = "A small set of Python functions to draw pretty maps from OpenStreetMap data";
    license = licenses.agpl3;
  };
}
