{ stdenv
, buildPythonPackage
, fetchFromGitLab
, ldap0
, paramiko
, asn1crypto
, xlwt
, dnspython
}:

buildPythonPackage rec {
  pname = "web2ldap";
  version = "1.5.75";

  propagatedBuildInputs = [ ldap0 paramiko asn1crypto xlwt dnspython ];

  doCheck = false; # no tests

  src = fetchFromGitLab {
    owner = "ae-dir";
    repo = "web2ldap";
    rev = "v${version}";
    sha256 = "1f10qnh94fcwdkvdamac96501hbs1fxb4kgz673j7xd8cx3a77ci";
  };

  makeWrapperArgs = [
    "--prefix" "PYTHONPATH" ":" "${placeholder "out"}/etc/web2ldap"
    "--set" "WEB2LDAP_HOME" "${placeholder "out"}"
  ];

  meta = with stdenv.lib; {
    description = "Full-featured LDAP client running as web application";
    homepage = "https://www.web2ldap.de";
    license = licenses.apsl20;
    platforms = platforms.unix;
  };
}

