{ stdenv, python37Packages, fetchurl}:

python37Packages.buildPythonPackage rec {
  pname = "pytest-flask";
  version = "0.14.0";
  name = "${pname}-${version}";
  
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/b9/b0/24eaa3f6f1fb1701c3fb4e5cc7e4ba68cf679e3def69c2f05fcff3a301e4/pytest-flask-0.14.0.tar.gz";
    sha256 = "df69f2b552098227d7b7a8a48d6df2742a4d865d0807eac4916fb622c2d47e1a";
  };
  
  propagatedBuildInputs =  with python37Packages; [pytest werkzeug flask setuptools_scm];
  doCheck = false;
  
  meta = with stdenv.lib; {
    homepage = "https://pytest-flask.readthedocs.io/en/latest/";
    description = "A plugin for pytest that provides a set of tools to test Flask applications.";
    license = licenses.mit;
  };
}
