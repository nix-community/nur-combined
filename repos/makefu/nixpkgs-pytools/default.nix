{ lib
, python3
}:
with python3.pkgs;
buildPythonPackage rec {
  pname = "nixpkgs-pytools";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "11skcbi1lf9qcv9j5ikifb4pakhbbygqpcmv3390j7gxsa85cn19";
  };

  propagatedBuildInputs = [
    jinja2
    setuptools
    rope
  ];
  checkInputs = [
    pytest
  ];

  meta = with lib; {
    description = "Tools for removing the tedious nature of creating nixpkgs derivations";
    homepage = https://github.com/nix-community/nixpkgs-pytools/;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
