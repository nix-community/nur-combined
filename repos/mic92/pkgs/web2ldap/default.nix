{ stdenv, buildPythonApplication, fetchFromGitLab
, ldap0, paramiko, asn1crypto, xlwt, dnspython }:

buildPythonApplication rec {
  pname = "web2ldap";
  version = "1.5.57";

  propagatedBuildInputs = [ ldap0 paramiko asn1crypto xlwt dnspython ];

  doCheck = false; # no tests

  src = fetchFromGitLab {
    owner = "ae-dir";
    repo = "web2ldap";
    rev = "v${version}";
    sha256 = "0z6q9vx2km3h5kd728sz7iy7v02wz5sgxswyb0s66b9jdi2v5741";
  };

  meta = with stdenv.lib; {
    description = "Full-featured LDAP client running as web application";
    homepage = https://www.web2ldap.de;
    license = licenses.apsl20;
    platforms = platforms.unix;
  };
}
