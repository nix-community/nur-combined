{ lib
, fetchpatch
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

  patches = [
    # Replace np subtract operator https://github.com/mapbox/supermercado/pull/27
    (
      fetchpatch {
        url = "https://github.com/mapbox/supermercado/commit/3a70bccad64557920121e81aded869d44581230c.patch";
        sha256 = "0zbzk1ac59q974yp1f7gz5hpvr2z54hjygynxi0a6vn1ii30mnwr";
      }
    )
  ];

  propagatedBuildInputs = with python3Packages; [ click-plugins rasterio mercantile numpy ];

  checkInputs = with python3Packages; [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    inherit (sources.supermercado) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
