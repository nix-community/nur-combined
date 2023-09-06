{ lib, buildPythonPackage, fetchPypi, setuptools }:

buildPythonPackage rec {
  pname = "warctools";
  version = "4.10.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0w31mv9f5anxgjvjv62w7yyavpp8x11kjyy9yw88ib5q9lknw36f";
  };

  propagatedBuildInputs = [ setuptools ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/internetarchive/warctools";
    description =
      "Command line tools and libraries for handling and manipulating WARC files (and HTTP contents)";
    license = licenses.mit;
  };
}
