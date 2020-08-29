{ lib
, buildPythonPackage
, fetchPypi
, debtcollector
, iso8601
, netaddr
, netifaces
, oslo-i18n
, packaging
, pbr
, pytz
}:
let 
  pyModuleDeps = [
    debtcollector
    iso8601
    netaddr
    netifaces
    oslo-i18n
    packaging
    pbr
    pytz
  ];
in
buildPythonPackage rec {
  pname = "oslo-utils";
  version = "4.4.0";

  src = fetchPypi {
    pname = "oslo.utils";
    inherit version;
    sha256 = "1yw4jaqnqvmmxvvd9ifsywhy41gaf4lcimgla5ygbpniwfqf20qn";
  };
  
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;
  
  # Needs internet connection
  doCheck = false;

  meta = with lib; {
    description = "Oslo Utility library";
    license = licenses.asl20;
    longDescription = ''
      The oslo.utils library provides support for common utility type
      functions, such as encoding, exception handling, string manipulation,
      and time handling.
    '';
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
