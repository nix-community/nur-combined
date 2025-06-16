{
  buildGoModule,
  go,
  fetchFromGitHub,
  lib,
  nix-update-script,
  olm,
}:

buildGoModule rec {
  pname = "matrix-qq";
  version = "0.2.1";
  src = fetchFromGitHub {
    owner = "duo";
    repo = "matrix-qq";
    rev = version;
    sha256 = "sha256-/ceiP67uoItCzrSB9YnCA8Fx27O1zBFScFFuAwrml5Y=";
  };

  vendorHash = "sha256-V4t6G9fh+lKeN49cD/Iy24KQNQXUunNSn9eS2mZRXx0=";

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
    description = "A Matrix-QQ puppeting bridge";
    homepage = "https://github.com/duo/matrix-qq";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ yinfeng ];
    broken = !(lib.versionAtLeast go.version "1.20");
  };
}
