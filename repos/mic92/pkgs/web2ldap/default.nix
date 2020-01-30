{ buildPythonApplication, fetchurl
, ldap0, paramiko, asn1crypto, xlwt, dnspython }:

buildPythonApplication rec {
  pname = "web2ldap";
  version = "1.5.49";

  propagatedBuildInputs = [ ldap0 paramiko asn1crypto xlwt dnspython ];

  doCheck = false; # no tests

  src = fetchurl {
    url = "https://www.web2ldap.de/download/web2ldap-${version}.tar.gz";
    sha256 = "0lkivpimw6igfbadjyqd4f0jahq2vc88bd3qqlk956j50q38fis9";
  };
}
