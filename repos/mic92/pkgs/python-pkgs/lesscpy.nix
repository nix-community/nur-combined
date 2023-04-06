{ lib
, buildPythonPackage
, fetchFromGitHub
, six
, ply
, nose
, flake8
, glibcLocales
}:

buildPythonPackage rec {
  pname = "lesscpy";
  version = "0.15.0";
  propagatedBuildInputs = [ six ply ];
  checkInputs = [ nose flake8 glibcLocales ];
  src = fetchFromGitHub {
    owner = "lesscpy";
    repo = "lesscpy";
    rev = version;
    sha256 = "sha256-Uy3BVz1kuFlcBQnpR0i66l+XrlCYKxr/1pKl0pa7L+Y=";
  };
  LC_ALL = "en_US.utf8";
  meta = with lib; {
    description = "Python LESS Compiler";
    homepage = "https://github.com/lesscpy/lesscpy";
    license = licenses.mit;
  };
}
