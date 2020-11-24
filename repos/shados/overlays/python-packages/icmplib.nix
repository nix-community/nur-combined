{ stdenv, fetchPypi, buildPythonPackage }:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "icmplib";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0s4hjykb5jmgd7yaj0i4lsx8f0fhdx0lsd2fi79kznlchsn12nl4";
  };

  doCheck = false;
  buildInputs = [];
  propagatedBuildInputs = [
  ];
  meta = with stdenv.lib; {
    homepage = "https://github.com/ValentinBELYN/icmplib";
    license = licenses.lgpl3;
    maintainer = with mainters; [ arobyn ];
    description = ''
      icmplib is a brand new and modern implementation of the ICMP protocol in
      Python.
    '';
  };
}
