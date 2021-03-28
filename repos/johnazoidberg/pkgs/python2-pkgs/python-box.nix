{ stdenv, lib, fetchFromGitHub, pytestrunner, buildPythonPackage }:
buildPythonPackage rec {
  pname = "python-box";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "cdgriffith";
    repo = "Box";
    rev = version;
    sha256 = "0b7i65bb6wbba3f6s01pxm6mmfvnb5szr3xqspmzkf1n8d2m321j";
  };

  propagatedBuildInputs = [
    pytestrunner
  ];

  checkPhase = "true";

  meta = with lib; {
    description = "Python dictionaries with advanced dot notation access";
    license = licenses.mit;
    homepage = https://github.com/cdgriffith/Box;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
