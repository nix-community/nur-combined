{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, requests
}:

buildPythonPackage rec {
  pname = "update-checker";
  version = "0.18.0";
  src = fetchFromGitHub {
    owner = "bboe";
    repo = "update_checker";
    rev = "v${version}";
    sha256 = "sha256-41Vp65hJDmyDePk4Kl3wY73Uxwe4jBzuQa7oLrJapYA=";
  };
  propagatedBuildInputs = [
    requests
  ];
  meta = with lib; {
    homepage = "https://github.com/bboe/update_checker";
    description = "A python module that will check for package updates";
    license = licenses.bsd2;
  };
}
