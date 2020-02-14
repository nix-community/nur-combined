{ stdenv, buildPythonPackage, fetchFromGitHub, pytest }:
buildPythonPackage rec {
  pname = "flake8-annotations-complexity";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "best-doctor";
    repo = pname;
    rev = "6d606309baa372a2c49863527f2d1aa2d98f480b";
    sha256 = "1l63vh7xa0dc50i8pxqxhw6cc0gkz5mlcb4jg91gqwiml6y3yq9q";
  };

  checkInputs = [ pytest ];
  checkPhase = ''
    ${pytest}/bin/pytest
  '';

  meta = with stdenv.lib; {
    description = "A flake8 extension that checks for type annotations complexity";
    homepage = https://github.com/best-doctor/flake8-annotations-complexity;
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}

