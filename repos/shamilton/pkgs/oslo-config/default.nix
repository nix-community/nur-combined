{ lib
, buildPythonPackage
, fetchPypi
, debtcollector
, importlib-metadata
, netaddr
, oslo-i18n
, pbr
, pyyaml
, requests
, rfc3986
, stevedore
, breakpointHook
}:
let 
  pyModuleDeps = [
    debtcollector
    importlib-metadata
    netaddr
    oslo-i18n
    pbr
    pyyaml
    requests
    rfc3986
    stevedore
  ];
in
buildPythonPackage rec {
  pname = "oslo-config";
  version = "8.3.1";

  src = fetchPypi {
    pname = "oslo.config";
    inherit version;
    sha256 = "1z47kszi1m9gvw4m7xnfy9knln0p5wjnffbgp7wdv1jcbgf87fyz";
  };
  
  nativeBuildInputs = [ breakpointHook ];
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;

  # Needs internet connection
  doCheck = false;

  meta = with lib; {
    description = "Oslo Configuration API";
    license = licenses.asl20;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
