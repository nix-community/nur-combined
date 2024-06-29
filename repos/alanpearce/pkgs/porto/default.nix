{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "porto";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "jcchavezs";
    repo = "porto";
    rev = "v${version}";
    hash = "sha256-0Wu5F95f7EaDL7kiJudlq2ioHxXx/sUXqVKwg/n/Cx0=";
  };

  vendorHash = "sha256-doUt43BWXFKYDdl6aHWeMvZEyxh+otHAfA4X+yqBTas=";
  subPackages = [ "cmd/porto" ];

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Tool for adding vanity import to Go code";
    homepage = "https://github.com/jcchavezs/porto";
    license = licenses.asl20;
    maintainers = with maintainers; [ alanpearce ];
    mainProgram = "porto";
  };
}
