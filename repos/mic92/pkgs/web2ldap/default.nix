{ stdenv, buildPythonApplication, fetchurl
, ldap0, paramiko, asn1crypto, xlwt, dnspython }:

buildPythonApplication rec {
  pname = "web2ldap";
  version = "1.5.53";

  propagatedBuildInputs = [ ldap0 paramiko asn1crypto xlwt dnspython ];

  doCheck = false; # no tests

  src = fetchurl {
    url = "https://www.web2ldap.de/download/web2ldap-${version}.tar.gz";
    sha256 = "1sd974sgd38lsvv797i7afjw9fw4zkclpjy3yh87nwwj9qx79q8d";
  };

  meta = with stdenv.lib; {
    description = "Full-featured LDAP client running as web application";
    homepage = https://www.web2ldap.de;
    license = licenses.apsl20;
    platforms = platforms.unix;
  };
}
