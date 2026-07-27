{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "indexedproperty";
  version = "0.1.4";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-sLfNoHG2dpjkAVE6UZKj3NahjqBEQw4I15dlj5yr7sg=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools-scm
  ];
  buildInputs = with python3Packages; [ setuptools ];
  pyproject = true;

  meta = with lib; {
    description = ''Provides indexed properties on class instances'';
    homepage = "https://github.com/NJDFan/indexedproperty";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
