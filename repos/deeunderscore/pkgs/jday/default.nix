{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "jday";
  version = "2.4";

  src = fetchurl {
    url = "mirror://sourceforge/jday/jday/${version}/jday-${version}.tar.gz";
    sha256 = "sha256-OxXzobVS/658NDvUe/iegHPanvjC7G15uQ1W+MOgb9o=";
  };

  meta = with lib; {
    description = "Julian date calculator";
    homepage = "http://jday.sourceforge.net/jday.html";
    license = licenses.bsd3;
  };

}
