{ stdenv
, buildPythonPackage
, fetchFromGitLab
, openldap
, cyrus_sasl
, pyasn1
, pyasn1-modules
, breakpointHook
}:

buildPythonPackage rec {
  pname = "ldap0";
  version = "1.0.6";

  src = fetchFromGitLab {
    owner = "ae-dir";
    repo = "python-ldap0";
    rev = "v${version}";
    sha256 = "05xipdzpz3hp2wswgvdbgl7ir6mawyh19r0r5balgk2byf3mf14s";
  };

  SBIN = "${openldap}/libexec";
  BIN = "${openldap}/bin";
  SLAPD = "${openldap}/libexec/slapd";
  SCHEMA = "${openldap}/etc/schema";

  buildInputs = [ openldap cyrus_sasl ];
  propagatedBuildInputs = [ pyasn1 pyasn1-modules ];
  meta = with stdenv.lib; {
    description = "Object-oriented API to access LDAP directory servers";
    homepage = "https://gitlab.com/ae-dir/python-ldap0";
    license = licenses.asl20;
  };
}
