{ pythonPackages }: with pythonPackages;
buildPythonPackage rec {
  pname = "wokkel";
  version = "18.0.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1spq44gg8gsviqx1dvlmjpgfc0wk0jpyx4ap01y2pad1ai9cw016";
  };
  propagatedBuildInputs = [ twisted.extras.tls twisted incremental dateutil ];
  doCheck = false;
}
