{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mieru";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "enfein";
    repo = "mieru";
    rev = "v${version}";
    hash = "sha256-QNF0cAVGLonl2HuDVJQyexFSoCcDK2s/I/7aNMV/FLc=";
  };

  vendorHash = "sha256-OVTBoQmvsirpZsrJS/xxkFFlxOFFu+Jy4dSmAvj7Es4=";
  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "A socks5 / HTTP / HTTPS proxy to bypass censorship";
    homepage = "https://github.com/enfein/mieru";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "mieru";
  };
}
