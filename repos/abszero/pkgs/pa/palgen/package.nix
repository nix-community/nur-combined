{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "palgen";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = "palgen";
    rev = "v${version}";
    hash = "sha256-jqc4qJKXNyCQDiZnykpMRTN6G6yYnsQdIBaiqStTPu0=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Convert png to palettes in various formats";
    homepage = "https://github.com/xyproto/palgen";
    license = licenses.bsd3;
    maintainers = with maintainers; [ weathercold ];
    platforms = platforms.all;
  };
}
