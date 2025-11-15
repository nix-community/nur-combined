{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "geoip2fast";
  version = "1.2.2";
  pyproject = true;

  src = fetchPypi {
    pname = "geoip2fast";
    inherit version;
    sha256 = "38815700cedfeb197d51b4b8733b0d4f7965b36de15147c125527124f8b45d6b";
  };

  build-system = [ setuptools ];

  meta = {
    description = "GeoIP2Fast is the fastest GeoIP2 country/city/asn lookup library";
    mainProgram = "geoip2fast";
    homepage = "https://github.com/rabuchaim/geoip2fast";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.platforms.unix;
  };
}
