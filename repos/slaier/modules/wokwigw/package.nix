{ lib
, buildGoModule
, fetchFromGitHub
, libpcap
,
}:

buildGoModule rec {
  pname = "wokwigw";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "wokwi";
    repo = "wokwigw";
    rev = "v${version}";
    hash = "sha256-V/99dpaJjUZlMrjAGSI8xSMQGYS/YLP08DDa89Ymv6w=";
  };

  vendorHash = "sha256-i9/O21iFxwk2YWneWeBXDm79EeMnuoA6MQ74A7KVKIE=";

  buildInputs = [
    libpcap
  ];

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Wokwi IoT Network Gateway";
    homepage = "https://github.com/wokwi/wokwigw";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "wokwigw";
  };
}
