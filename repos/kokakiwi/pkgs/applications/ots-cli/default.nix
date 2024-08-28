{ lib
, _common

, buildGoModule
}:
buildGoModule rec {
  pname = "ots-cli";
  inherit (_common) version src;

  modRoot = "cmd/ots-cli";

  vendorHash = "sha256-dSva/7iCmMVH0KCE5mHQFCZfBfSi9iEoyY2DMHRIhdI=";

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
