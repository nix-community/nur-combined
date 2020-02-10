{ lib, fetchpatch, buildPythonApplication
, click-plugins, rasterio, mercantile, numpy, pytest, supermercado }:

buildPythonApplication rec {
  pname = "supermercado";
  version = lib.substring 0 7 src.rev;
  src = supermercado;

  patches = [
    # Replace np subtract operator https://github.com/mapbox/supermercado/pull/27
    (fetchpatch {
      url = "https://github.com/mapbox/supermercado/commit/3a70bccad64557920121e81aded869d44581230c.patch";
      sha256 = "0zbzk1ac59q974yp1f7gz5hpvr2z54hjygynxi0a6vn1ii30mnwr";
    })
  ];

  propagatedBuildInputs = [ click-plugins rasterio mercantile numpy ];

  checkInputs = [ pytest ];
  checkPhase = "pytest";

  meta = with lib; {
    description = supermercado.description;
    homepage = supermercado.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
