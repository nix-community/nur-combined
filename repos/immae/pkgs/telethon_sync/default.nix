{ lib, python3Packages }:
with python3Packages;
buildPythonPackage rec {
  pname = "Telethon-sync";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 =
      "01z8fzqn0qs5pxhvzq891r3mwffq1ga3f8xvm7qdn6kvmxjni9fy";
  };

  propagatedBuildInputs = [
    rsa pyaes async_generator
  ];
  doCheck = false;

  meta = with lib; {
    homepage = https://github.com/LonamiWebs/Telethon;
    description = "Full-featured Telegram client library for Python 3";
    license = licenses.mit;
  };
}
