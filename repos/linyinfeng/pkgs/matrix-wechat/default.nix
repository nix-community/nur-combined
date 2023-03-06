{ buildGoModule, fetchFromGitHub, lib, nix-update-script, olm }:

buildGoModule rec {
  pname = "matrix-wechat";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-wechat";
    rev = version;
    sha256 = "sha256-lRrKnZ2YcVX6bFgqcd4glKtFawuxlKdd7fY2GRM46eA=";
  };

  vendorSha256 = "sha256-GkXKuBucirEuql2t/FGw9agbF+lfYmT2x0+AkyMH2ds=";

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
