{ python3Packages
, generated
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  inherit (generated) pname version src;

  nativeBuildInputs = [
    beets
    setuptools-scm
  ];

  propagatedBuildInputs = [ jsonpath_rw ];

  # There's no test
  doCheck = false;

  # pythonImportsCheck = [ "beetsplug.originquery" ];

  meta = {
    description = "Plugin for beets that improves album matching";
    homepage = "https://github.com/x1ppy/beets-originquery";
  };
}
