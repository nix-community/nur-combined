{ buildGoModule, fetchFromGitHub, lib, nix-update-script, olm }:

buildGoModule rec {
  pname = "matrix-wechat";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-wechat";
    rev = version;
    sha256 = "sha256-01hA5Jwcr36QhWlolz1EAiXr+Em/dGJxL2pBCHV4ow8=";
  };

  vendorSha256 = "sha256-nGQlMS/SB7ytVFcMxPm4U2AA0j9B6MJZF+/PVPtUf8M=";

  buildInputs = [
    olm
  ];

  ldflags = [
    "-s"
    "-w"
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
