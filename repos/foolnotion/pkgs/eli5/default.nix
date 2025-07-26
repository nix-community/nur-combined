{ lib, pythonPackages, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
    pname = "eli5";
    version = "0.15.0";

    src = fetchPypi {
      inherit pname version;

      sha256 = "sha256-cRYw3vYBcHs9N6o8M9OaHSEruAF7VYp7ZCS64cMgowM=";
    };

    buildInputs = with pythonPackages; [ attrs scikitlearn graphviz six tabulate jinja2 ];

    doCheck = false;

    meta = with lib; {
      homepage = "https://eli5.readthedocs.io";
      description = "Python library which allows to visualize and debug various Machine Learning models using unified API.";
      license = licenses.mit;
      broken = true;
    };
}
