{ stdenv
, buildPythonPackage
, fetchPypi
, openldap
, cyrus_sasl
, pyasn1
, pyasn1-modules
, breakpointHook
}:

buildPythonPackage rec {
  pname = "ldap0";
  version = "0.6.8";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1d5q9x0yg23kgbwdy0mf03kkyjgiff5ywwy0px11pll0263sx414";
  };
  SBIN = "${openldap}/libexec";
  BIN = "${openldap}/bin";
  SLAPD = "${openldap}/libexec/slapd";
  SCHEMA = "${openldap}/etc/schema";
  buildInputs = [ openldap cyrus_sasl ];
  propagatedBuildInputs = [ pyasn1 pyasn1-modules ];
  nativeBuildInputs = [ breakpointHook ];
  meta = with stdenv.lib; {
    description = "Object-oriented API to access LDAP directory servers";
    homepage = https://gitlab.com/ae-dir/python-ldap0;
    license = licenses.asl20;
  };
}
