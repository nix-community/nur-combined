{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "wzshiming-socks5";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "wzshiming";
    repo = "socks5";
    rev = "v${version}";
    hash = "sha256-PiXZHZaPw7QMFMnMwcCwpAxK8kG/Le13OLYOps5Pu5E=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Socks5/Socks5h server and client. Full TCP/Bind/UDP and IPv4/IPv6 support";
    homepage = "https://github.com/wzshiming/socks5";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "socks5";
  };
}
