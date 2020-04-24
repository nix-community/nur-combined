{ pythonPackages, libmilter }: with pythonPackages;
buildPythonPackage rec {
  pname = "pymilter";
  version = "1.0.4";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1bpcvq7d72q0zi7c8h5knhasywwz9gxc23n9fxmw874n5k8hsn7k";
  };
  doCheck = false;
  buildInputs = [ libmilter ];
}
