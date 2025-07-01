{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "porto";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "jcchavezs";
    repo = "porto";
    rev = "v${version}";
    hash = "sha256-YFhUjDv8b7i+ezktdAn37SB8bwhpxUyXtNWbEBinX90=";
  };

  vendorHash = "sha256-MTuwMP3pnaIBt3FPNPJNaEncpTBVTlTxScQuRKj5b/U=";
  subPackages = [ "cmd/porto" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Tool for adding vanity import to Go code";
    homepage = "https://github.com/jcchavezs/porto";
    license = licenses.asl20;
    maintainers = with maintainers; [ alanpearce ];
    mainProgram = "porto";
  };
}
