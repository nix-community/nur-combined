{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "pyfemm";
  version = "0.1.3";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-MLIuXT9BCl5QpzVeybl3EtN+l/pryPwMjFFZg7WYZA0=";
  };

  doCheck = false;
  buildInputs = with python3Packages; [ setuptools ];
  pyproject = true;

  meta = with lib; {
    description = ''Python interface to Finite Element Method Magnetics (FEMM)'';
    homepage = "https://www.femm.info/wiki/pyFEMM";
    license = licenses.aladdin;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
