{ fetchPypi, buildPythonPackage, pygtrie, ... }:
buildPythonPackage rec {
  pname = "betacode";
  version = "0.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "08fnjzjvnm9m6p4ddyr8qgfb9bs2nipv4ls50784v0xazgxx7siv";
  };
  preBuild = ''echo > README.rst'';
  propagatedBuildInputs = [ pygtrie ];
  doCheck = false;
}
