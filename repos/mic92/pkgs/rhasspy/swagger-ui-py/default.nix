{ lib
, buildPythonPackage
, fetchFromGitHub
, jinja2
, pyyaml
}:

buildPythonPackage rec {
  pname = "swagger-ui-py";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "PWZER";
    repo = "swagger-ui-py";
    rev = "v${version}";
    sha256 = "1910zvkp2613s4ysb61k2gkaw3m1hdg2433kbqil80mqm915i1ix";
  };

  propagatedBuildInputs = [
    pyyaml
    jinja2
  ];

  meta = with lib; {
    description = "The kitchen sink of Python utility libraries for doing stuff in a functional way. Based on the Lo-Dash Javascript library";
    homepage = "https://github.com/PWZER/swagger-ui-py";
    license = licenses.asl20;
  };
}
