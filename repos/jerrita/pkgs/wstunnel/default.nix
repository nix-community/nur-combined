{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "wstunnel";
  version = "9.7.4";

  src = fetchFromGitHub {
    owner = "erebe";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-OFm0Jk06Mxzr4F7KrMBGFqcDSuTtrMvBSK99bbOgua4=";
  };

  cargoHash = "sha256-JMRcXuw6AKfwViOgYAgFdSwUeTo04rEkKj+t+W8wjGI=";

  meta = {
    description = "Tunnel all your traffic over Websocket or HTTP2 - Bypass firewalls/DPI";
    homepage = "https://github.com/erebe/wstunnel";
    license = lib.licenses.bsd3;
  };
}
