{ buildGoModule, fetchFromGitHub, lib, nix-update-script, olm }:

buildGoModule rec {
  pname = "matrix-wechat";
  version = "0.2.1";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-wechat";
    rev = version;
    sha256 = "sha256-X/dufOaHQdN1AnlkNNUUpUrX77C9sMtLja3e9+sg0MI=";
  };

  vendorSha256 = "sha256-tovnLPZRaCD7tadmuO35jniG7wZqIgC57wsQxt3JYsA=";

  buildInputs = [
    olm
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Tag=${version}"
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "A Matrix-WeChat puppeting bridge";
    homepage = "https://github.com/duo/matrix-wechat";
    license = licenses.agpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
