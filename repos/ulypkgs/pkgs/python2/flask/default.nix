{
  lib,
  buildPythonPackage,
  fetchPypi,
  itsdangerous,
  click,
  werkzeug,
  jinja2,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  version = "1.1.2";
  pname = "Flask";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Tvoa4tfJhlr0iYbeiuuFBL8yx/PW/ck1PTSyH0sScGA=";
  };

  checkInputs = [ pytest ];
  propagatedBuildInputs = [
    itsdangerous
    click
    werkzeug
    jinja2
  ];

  checkPhase = ''
    py.test
  '';

  # Tests require extra dependencies
  doCheck = false;

  meta = with lib; {
    homepage = "http://flask.pocoo.org/";
    description = "A microframework based on Werkzeug, Jinja 2, and good intentions";
    license = licenses.bsd3;
  };
})
