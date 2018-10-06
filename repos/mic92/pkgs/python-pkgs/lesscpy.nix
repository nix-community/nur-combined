{ stdenv, buildPythonPackage, fetchFromGitHub
, six, ply
, nose, flake8, glibcLocales }:

buildPythonPackage rec {
  pname = "lesscpy";
  version = "0.13.0";
  propagatedBuildInputs = [ six ply ];
  checkInputs = [ nose flake8 glibcLocales ];
  src = fetchFromGitHub {
    owner = "lesscpy";
    repo = "lesscpy";
    rev = version;
    sha256 = "1jf5bp4ncvw2gahhkvjy5b0366y9x3ki9r9c5n6hkvifjk3jhmb2";
  };
  LC_ALL = "en_US.utf8";
  meta = with stdenv.lib; {
    description = "Python LESS Compiler";
    homepage = https://github.com/lesscpy/lesscpy;
    license = licenses.mit;
  };
}
