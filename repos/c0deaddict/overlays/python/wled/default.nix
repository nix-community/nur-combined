{ stdenv, fetchPypi, buildPythonPackage
, pytest, attrs, cattrs, aiohttp }:

buildPythonPackage rec {
  pname = "wled";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1j0g0bc333nc85n68s87b8j1sni7jr7q8wjk9awqp5ndhdb60wj9";
  };

  nativeBuildInputs = [ attrs ];
  propagatedBuildInputs = [ aiohttp cattrs ];

  # Test are not included in pypi.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "WLED API Client.";
    homepage = "https://pypi.org/project/wled";
    license = licenses.mit;
  };
}
