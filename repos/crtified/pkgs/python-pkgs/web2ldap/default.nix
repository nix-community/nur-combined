{ lib
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
  version = "1.6.7";

  propagatedBuildInputs = [ ldap0 paramiko asn1crypto xlwt dnspython ];

  doCheck = false; # no tests

  src = fetchFromGitLab {
    owner = "ae-dir";
    repo = "web2ldap";
    rev = "v${version}";
    sha256 = "142ksva10qkjznrq6h9cdfj2284ziwnfd8gvi20cj7fb2bpzjisj";
  };

  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    "${placeholder "out"}/etc/web2ldap"
    "--set"
    "WEB2LDAP_HOME"
    "${placeholder "out"}"
  ];

  meta = with lib; {
    description = "Full-featured LDAP client running as web application";
    homepage = "https://www.web2ldap.de";
    license = licenses.apsl20;
    platforms = platforms.unix;
  };
}
