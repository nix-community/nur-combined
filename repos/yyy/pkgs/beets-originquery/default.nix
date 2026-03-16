{ python3Packages
, generated
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pyproject = true;

  inherit (generated) pname version src;

  build-system = [ setuptools-scm ];

  nativeBuildInputs = [ beets ];

  propagatedBuildInputs = [ jsonpath-rw ];

  # There's no test
  doCheck = false;

  # pythonImportsCheck = [ "beetsplug.originquery" ];

  meta = {
    description = "Plugin for beets that improves album matching";
    homepage = "https://github.com/x1ppy/beets-originquery";
  };
}
