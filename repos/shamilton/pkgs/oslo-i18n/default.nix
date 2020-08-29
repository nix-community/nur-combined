{ lib
, buildPythonPackage
, fetchPypi
, pbr
, six
}:
let 
  pyModuleDeps = [
    pbr
    six
  ];
in
buildPythonPackage rec {
  pname = "oslo-i18n";
  version = "5.0.0";

  src = fetchPypi {
    pname = "oslo.i18n";
    inherit version;
    sha256 = "11v8zkqk8v19b8jj8ij0xmz2dp2369jyc1zlz1qsqx1sqwzaww9f";
  };
  
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;
  
  # Needs internet connection
  doCheck = false;

  meta = with lib; {
    description = "Openstack internationalization and translation library";
    license = licenses.asl20;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
