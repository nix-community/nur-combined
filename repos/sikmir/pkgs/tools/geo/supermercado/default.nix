{ lib
, python3Packages
, mercantile
, sources
}:
let
  pname = "supermercado";
  date = lib.substring 0 10 sources.supermercado.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.supermercado;

  propagatedBuildInputs = with python3Packages; [ click-plugins rasterio mercantile numpy ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.supermercado) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
