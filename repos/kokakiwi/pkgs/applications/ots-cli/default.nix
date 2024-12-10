{ lib
, _common

, buildGoModule
}:
buildGoModule rec {
  pname = "ots-cli";
  inherit (_common) version src;

  modRoot = "cmd/ots-cli";

  vendorHash = "sha256-p6WAovm3t4oV2LjOlbIuwBEL8JUIUO5/htimqIonMJo=";

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
