{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "straight-plugin";
  version = "1.5.0";

  src = fetchPypi {
    pname = "straight.plugin";
    inherit version;
    sha256 = "818a7641068932ed6436d0af0a3bb77bbbde29df0a7142c8bd1a249e7c2f0d38";
  };

  meta = with lib; {
    description = "A simple namespaced plugin facility";
    homepage = https://github.com/ironfroggy/straight.plugin;
    license = licenses.mit;
    maintainers = [ maintainers.makefu ];
  };
}
