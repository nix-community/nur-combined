{ lib, buildPythonPackage, fetchFromGitLab, openldap, cyrus_sasl, pyasn1
, pyasn1-modules, breakpointHook }:

buildPythonPackage rec {
  pname = "ldap0";
  version = "1.2.11";

  src = fetchFromGitLab {
    owner = "ae-dir";
    repo = "python-ldap0";
    rev = "v${version}";
    sha256 = "1k7d4ymh10nkgpb4mbs608fb4vzjafwhjaxbj4zxa6pya5xn0p5v";
  };

  SBIN = "${openldap}/libexec";
  BIN = "${openldap}/bin";
  SLAPD = "${openldap}/libexec/slapd";
  SCHEMA = "${openldap}/etc/schema";

  buildInputs = [ openldap cyrus_sasl ];
  propagatedBuildInputs = [ pyasn1 pyasn1-modules ];
  meta = with lib; {
    description = "Object-oriented API to access LDAP directory servers";
    homepage = "https://gitlab.com/ae-dir/python-ldap0";
    license = licenses.asl20;
  };
}
