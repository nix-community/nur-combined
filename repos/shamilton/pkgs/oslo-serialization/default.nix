{ lib
, buildPythonPackage
, fetchPypi
, msgpack
, oslo-utils
, pbr
, pytz
}:
let 
  pyModuleDeps = [
    msgpack
    oslo-utils
    pbr
    pytz
  ];
in
buildPythonPackage rec {
  pname = "oslo-serialization";
  version = "4.0.0";

  src = fetchPypi {
    pname = "oslo.serialization";
    inherit version;
    sha256 = "0q58am92m53ax4mszsb00xdmxbmnynawhvp8ncn2hr753cbxyrgl";
  };
  
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;
  
  # Needs internet connection
  doCheck = false;

  meta = with lib; {
    description = "Oslo Serialization library";
    license = licenses.asl20;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
