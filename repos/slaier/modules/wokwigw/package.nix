{ lib
, buildGoModule
, fetchFromGitHub
, libpcap
,
}:

buildGoModule rec {
  pname = "wokwigw";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "wokwi";
    repo = "wokwigw";
    rev = "v${version}";
    hash = "sha256-pCkWvRKb5xNQcT9BXaXbz56LaylmE+au8uWBB2D+9gs=";
  };

  vendorHash = "sha256-+5VStC4hKebsUJjtGm7/PnscVlpKYFf9BM5fwfDfFMA=";

  buildInputs = [
    libpcap
  ];

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Wokwi IoT Network Gateway";
    homepage = "https://github.com/wokwi/wokwigw";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wokwigw";
  };
}
