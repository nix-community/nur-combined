{ lib, pythonPackages, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
    pname = "eli5";
    version = "0.11.0";

    src = fetchPypi {
      inherit pname version;

      sha256 = "0mm0b9sv6g4bh4wmd3ij2bd07pjqydki8w8rncaycz0mx4dvb9xf";
    };

    buildInputs = with pythonPackages; [ attrs scikitlearn graphviz six tabulate jinja2 ];

    doCheck = false;

    meta = with lib; {
      homepage = "https://eli5.readthedocs.io";
      description = "Python library which allows to visualize and debug various Machine Learning models using unified API.";
      license = licenses.mit;
    };
}
