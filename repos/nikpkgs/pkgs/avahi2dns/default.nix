{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  pname = "avahi2dns";
  version = "0.0.2";

in
buildGoModule rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "LouisBrunner";
    repo = pname;
    rev = version;
    hash = "sha256-XDYfejTY/487vQC1msmvGqEhMVKjsKylbbaHDd2PvtI=";
  };

  vendorHash = "sha256-ojxhcop1nMhR1XYfMgmVcYReq0EwjBY3rxujHQ07I5Y=";

  meta = with lib; {
    description = "Small DNS server which interface with avahi (perfect for Alpine Linux and musl)";
    homepage = "https://github.com/LouisBrunner/avahi2dns";
    license = licenses.mit;
  };
}
