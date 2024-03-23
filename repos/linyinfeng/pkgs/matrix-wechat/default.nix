{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  olm,
}:

buildGoModule rec {
  pname = "matrix-wechat";
  version = "0.2.4";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-wechat";
    rev = version;
    sha256 = "sha256-V0BHOQghN73Kc8KDJ/jjRwhd7RLH57h05G9ge7QtJbY=";
  };

  vendorHash = "sha256-20xi3dcdSt5SRWUhmF7fZkSB6TzC/Z697M18v1kjLhg=";

  buildInputs = [ olm ];

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
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ yinfeng ];
    broken = !(versionAtLeast (versions.majorMinor trivial.version) "23.11");
  };
}
