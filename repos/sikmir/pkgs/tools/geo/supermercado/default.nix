{ lib
, python3Packages
, mercantile
, sources
}:

python3Packages.buildPythonApplication {
  pname = "supermercado-unstable";
  version = lib.substring 0 10 sources.supermercado.date;

  src = sources.supermercado;

  propagatedBuildInputs = with python3Packages; [ click-plugins rasterio mercantile numpy ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.supermercado) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
