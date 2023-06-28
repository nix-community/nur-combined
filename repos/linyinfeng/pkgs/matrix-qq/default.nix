{ buildGoModule
, go
, fetchFromGitHub
, lib
, nix-update-script
, olm
}:

buildGoModule rec {
  pname = "matrix-qq";
  version = "0.1.8";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = version;
    sha256 = "sha256-2PuW0bb4X2+ERPaE6E7rfnb6btsvDccfvpsYgvQ0g0M=";
  };

  vendorSha256 = "sha256-HTI5eailhCJ41u1094HS46hE3623j8IfhD3SIf8s7p8=";

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
    description = "A Matrix-QQ puppeting bridge";
    homepage = "https://github.com/duo/matrix-qq";
    license = licenses.agpl3;
    maintainers = with maintainers; [ yinfeng ];
    broken = !(lib.versionAtLeast go.version "1.20");
  };
}
