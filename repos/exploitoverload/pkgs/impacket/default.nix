{ lib, fetchFromGitHub, python3}:

python3.pkgs.buildPythonApplication rec {
  pname = "impacket";
  version = "${pname}_0_10_0";

  src = fetchFromGitHub {
      owner = "fortra";
      repo = "impacket";
      rev = "refs/tags/${version}";
      hash = "sha256-Vnl2sFKwbAqfKT4sM8mHs9IvWAMpD6QYtVjnV6S3d+8=";
    };

  propagatedBuildInputs = with python3.pkgs; [
    ldap3
    pyopenssl
    pycryptodomex
    future
    ldapdomaindump
    six
    chardet
    flask
    setuptools
  ];
  
  doCheck = false;

  meta = with lib; {
    description = "Impacket is a collection of Python classes for working with network protocols. ";
    homepage = "https://github.com/fortra/impacket";
    platforms = platforms.unix;
  };
}
