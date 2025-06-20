{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "geoip2fast";
  version = "1.2.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "rabuchaim";
    repo = "geoip2fast";
    rev = "3d1e2692e3dba2efab66416d50698e2c4ec88369";
    hash = "sha256-nqmsD8ftJTLsXZkw19W12wVNmlDgKrwfpgJ98TCmfUQ=";
  };

  meta = {
    description = "GeoIP2Fast is the fastest GeoIP2 country/city/asn lookup library";
    homepage = "https://github.com/rabuchaim/geoip2fast";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
