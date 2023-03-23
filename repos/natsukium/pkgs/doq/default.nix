{
  lib,
  buildPythonApplication,
  fetchPypi,
  pythonRelaxDepsHook,
  parso,
  jinja2,
  toml,
  ...
}:
buildPythonApplication rec {
  pname = "doq";
  version = "0.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uszDSN35Z8i/Mr/fVNqDJuHcdPN4ZeLBdgEq0Lx+6h4=";
  };

  nativeBuildInputs = [pythonRelaxDepsHook];
  pythonRelaxDeps = true;
  propagatedBuildInputs = [parso jinja2 toml];

  doCheck = false;

  meta = with lib; {
    description = "Docstring generator";
    homepage = "https://github.com/heavenshell/py-doq";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
