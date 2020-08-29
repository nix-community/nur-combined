{ lib
, buildPythonPackage
, fetchPypi
, iso8601
, os-service-types
, pbr
, requests
, stevedore
}:
let 
  pyModuleDeps = [
    iso8601
    os-service-types
    pbr
    requests
    stevedore
  ];
in
buildPythonPackage rec {
  pname = "keystoneauth1";
  version = "4.2.1";

  src = fetchPypi {
    pname = "keystoneauth1";
    inherit version;
    sha256 = "18c9khnk31i23x8mhvyrlh9gvhdphi3ac2p1f59d1wzg4z6bz5ll";
  };
  
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;
  
  # Needs internet connection
  doCheck = false;

  meta = with lib; {
    description = "Authentication Library for OpenStack Identity";
    license = licenses.asl20;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
