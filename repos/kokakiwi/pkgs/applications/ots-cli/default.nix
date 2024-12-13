{ lib
, _common

, buildGoModule
}:
buildGoModule rec {
  pname = "ots-cli";
  inherit (_common) version src;

  modRoot = "cmd/ots-cli";

  vendorHash = "sha256-dOilRnl6aW4tR5TJ30DTuTlAVcUT696ffdI34Q76O1U=";

  ldflags = [
    "-X main.version=${version}"
  ];
  subPackages = [ "." ];

  meta = with lib; {
    homepage = "https://ots.fyi";
    license = licenses.asl20;
    mainProgram = "ots-cli";
  };
}
