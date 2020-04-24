{ lib, python3Packages, fetchgit }:
with python3Packages;
buildPythonPackage rec {
  pname = "Telethon-sync";
  version = "1.1.1";

  src = fetchgit {
    url = "https://github.com/LonamiWebs/Telethon";
    branchName = "sync-stale";
    rev = "6a785a01aa56cfd21c8c5beb9d722c68d664ba5e";
    sha256 = "0g7gnln5kbh1gy6sfb3jg6knmi33n6sgzy2rni2x6af84lza0lgc";
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
