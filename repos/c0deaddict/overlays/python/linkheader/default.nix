{ lib, stdenv, fetchPypi, buildPythonPackage
, pytest }:

buildPythonPackage rec {
  pname = "LinkHeader";
  version = "0.4.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1hsh3gr8d5mc91c396xj33bv6zbfi0f7xnvi0m9vryx31dfc7fvz";
  };

  checkInputs = [ pytest ];
  propagatedBuildInputs = [ ];

  meta = with lib; {
    description = "Parse and format link headers according to RFC 5988 \"Web Linking\"";
    homepage = "https://pypi.org/project/LinkHeader";
    # License is "BSD UNKNOWN"
    # license = licenses.bsd;
  };
}
